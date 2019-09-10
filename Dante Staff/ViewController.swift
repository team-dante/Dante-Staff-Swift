//
//  ViewController.swift
//  Dante Staff
//
//  Created by Hung Phan on 7/11/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit
import FirebaseAuth
import LocalAuthentication
import Firebase

class ViewController: UIViewController {
    
    var handle: AuthStateDidChangeListenerHandle?
    var isChecked = true
    var loggedInBtnPressed = false

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loginView: UIView!
    // add the top constraint to move the text fields above the keyboard
    @IBOutlet weak var moveBothTextFieldsUp: NSLayoutConstraint!
    @IBOutlet weak var loginIcon: UIImageView!
    @IBOutlet weak var phoneTextField: CustomTextField!
    @IBOutlet weak var pinTextField: CustomTextField!
    @IBOutlet weak var loginButton: CustomButton!
    @IBOutlet weak var uncheckedBox: UIImageView!
    @IBAction func rememberMeBtnPressed(_ sender: UIButton) {
        activateBtn(bool: !isChecked)
    }
    @IBAction func loginBtnPress(_ sender: Any) {
        loggedInBtnPressed = true
        if (isChecked == false) {
            UserDefaults.standard.set(true, forKey: "turnOffFaceID")
        }
        else if (isChecked == true) {
            UserDefaults.standard.set(false, forKey: "turnOffFaceID")
        }
        guard var email = self.phoneTextField.text, var password = self.pinTextField.text else {
            self.errorLabel.text = "Email or password cannot be empty."
            self.errorLabel.isHidden = false
            self.phoneTextField.text = ""
            self.pinTextField.text = ""
            return
        }
        email += "@email.com"
        password += "ABCDEFG"
        self.showSpinner(onView: self.view)
    Database.database().reference().ref.child("Patients").queryOrdered(byChild: "patientPhoneNumber").queryEqual(toValue: phoneTextField.text).observeSingleEvent(of: .value) { (DataSnapshot) in
        if DataSnapshot.exists() {
            print("==>Staff logged in using Patient Account detected")
            self.removeSpinner()
            self.errorLabel.text = "Invalid credentials!"
            self.errorLabel.isHidden = false
            self.phoneTextField.text = ""
            self.pinTextField.text = ""
        }
        else {
            print("==>Staff logged in using approriate credentials.")
            Auth.auth().signIn(withEmail: email, password: password) {
                [weak self] user, error in
                guard let strongSelf = self else { return }
                
                strongSelf.removeSpinner()
                if let error = error {
                    strongSelf.errorLabel.text = error.localizedDescription
                    strongSelf.errorLabel.isHidden = false
                    strongSelf.phoneTextField.text = ""
                    strongSelf.pinTextField.text = ""
                    return
                }
                strongSelf.phoneTextField.text = ""
                strongSelf.pinTextField.text = ""
                strongSelf.performSegue (withIdentifier: "loginToMenu", sender: strongSelf)
            }
        }
    }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Hide the navigation bar on the this view controller
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        // The listener gets called whenever the user's sign-in state changes
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let userLocal = Auth.auth().currentUser {
                print("==> USER IS STILL SIGNED IN ==> ", userLocal.email!)
                let turnOffFaceId = UserDefaults.standard.bool(forKey: "turnOffFaceID")
                print("@@@@@@@\(turnOffFaceId)")
                if (!self.loggedInBtnPressed && turnOffFaceId == false) {
                    let myContext = LAContext()
                    let myLocalizedReasonString = "Log in to your account"
                    
                    var authError: NSError?
                    if #available(iOS 8.0, macOS 10.12.1, *) {
                        if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                            myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString) { success, evaluateError in
                                DispatchQueue.main.async {
                                    if success {
                                        self.performSegue(withIdentifier: "loginToMenu", sender: self)
                                    }
                                }
                            }
                        }
                    }
                    else {
                        // Fallback on earlier
                    }
                }
            }
            else {
                print("==> user is signed out ==> ", user?.email ?? "None")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        // Show the navigation bar on other view controllers
//         self.navigationController?.setNavigationBarHidden(false, animated: false)
        
       // detach listener
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.errorLabel.isHidden = true
        
        self.loginView.layer.cornerRadius = 12.0
        self.loginView.layer.shadowColor = UIColor.black.cgColor
        self.loginView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        self.loginView.layer.shadowRadius = 0.5
        self.loginView.layer.shadowOpacity = 0.5

        self.loginIcon.layer.shadowColor = UIColor.black.cgColor
        self.loginIcon.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        self.loginIcon.layer.shadowRadius = 0.5
        self.loginIcon.layer.shadowOpacity = 0.5
        
        self.addDoneButtonOnKeyboard()
        
        self.loginButton.backgroundColor = UIColor(displayP3Red: 0.205, green: 0.471, blue: 0.966, alpha: 1)
        
        // Pushes keyboard based on the y-position of a text input
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    func activateBtn(bool: Bool) {
        isChecked = bool
        
        if bool {
            uncheckedBox.image = UIImage(named: "checked-box")
        }
        else {
            uncheckedBox.image = UIImage(named: "unchecked-box")
        }
    }
    
    // decide what to do when the keyboard shows
    @objc func keyboardWillShow(notification:NSNotification) {
        let screenHeight = UIScreen.main.bounds.height
        
        self.view.layoutIfNeeded()
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let pinTextFieldFrame: CGRect = pinTextField.frame
            
            let lowerYPosition_pinTextField = pinTextFieldFrame.origin.y + pinTextFieldFrame.size.height
            let topYPositionKeyboard = screenHeight - keyboardHeight
            
            if (lowerYPosition_pinTextField > topYPositionKeyboard) {
                let offset = lowerYPosition_pinTextField -  topYPositionKeyboard
                print("offset ===>", offset)
                UIView.animate(withDuration: 0.25, animations: {
//                    self.moveBothTextFieldsUp.constant = 60 - offset
                    self.view.layoutIfNeeded()
    
                })
            }
        }

    }
    
    // decide what to do when keyboard hides
    @objc func keyboardWillHide(notification:NSNotification) {
        self.view.layoutIfNeeded()

        UIView.animate(withDuration: 0.25, animations: {
//            self.moveBothTextFieldsUp.constant = 75.0
            self.view.layoutIfNeeded()

        })
    }
    
    // add Done button on top of keyboard
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        phoneTextField.inputAccessoryView = doneToolbar
        pinTextField.inputAccessoryView = doneToolbar
    }
    @objc func doneButtonAction(){
        phoneTextField.resignFirstResponder()
        pinTextField.resignFirstResponder()
    }

}


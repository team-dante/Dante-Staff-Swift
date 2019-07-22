//
//  ViewController.swift
//  Dante Staff
//
//  Created by Hung Phan on 7/11/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit
import FirebaseAuth

var vSpinner : UIView?
extension UIViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}

extension UITextField {
    func underlined(){
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.gray.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var moveBothTextFieldsUp: NSLayoutConstraint!
    @IBOutlet weak var loginIcon: UIImageView!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var pinTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // The listener gets called whenever the user's sign-in state changes
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            // self.setTitleDisplay(user)
            //self.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        // self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
       // detach listener
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    @IBAction func loginBtnPress(_ sender: Any) {
        guard var email = self.phoneTextField.text, var password = self.pinTextField.text else {
            self.errorLabel.text = "Email or password cannot be empty."
            self.errorLabel.isHidden = false
            return
        }
        email += "@email.com"
        password += "ABCDEFG"
        self.showSpinner(onView: self.view)
        Auth.auth().signIn(withEmail: email, password: password) {
            [weak self] user, error in
            guard let strongSelf = self else { return }
            
            strongSelf.removeSpinner()
            if let error = error {
                strongSelf.errorLabel.text = error.localizedDescription
                strongSelf.errorLabel.isHidden = false
                return
            }
            strongSelf.performSegue (withIdentifier: "loginToMenu", sender: strongSelf)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.errorLabel.isHidden = true
        
        self.loginView.layer.cornerRadius = 10.0
        self.loginView.layer.shadowColor = UIColor.black.cgColor
        self.loginView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        self.loginView.layer.shadowRadius = 0.5
        self.loginView.layer.shadowOpacity = 0.5
        
        self.phoneTextField.underlined()
        phoneTextField.leftView =  UIView(frame: CGRect(x: 0, y: 0, width: 5, height: phoneTextField.frame.height))
        phoneTextField.leftViewMode = .always
        self.phoneTextField.layer.cornerRadius = 10.0
        self.phoneTextField.layer.shadowColor = UIColor.darkGray.cgColor
        self.phoneTextField.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        self.phoneTextField.layer.shadowRadius = 0.5
        self.phoneTextField.layer.shadowOpacity = 0.5
        
        self.pinTextField.underlined()
        pinTextField.leftView =  UIView(frame: CGRect(x: 0, y: 0, width: 5, height: pinTextField.frame.height))
        pinTextField.leftViewMode = .always
        self.pinTextField.layer.cornerRadius = 10.0
        self.pinTextField.layer.shadowColor = UIColor.darkGray.cgColor
        self.pinTextField.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        self.pinTextField.layer.shadowRadius = 0.5
        self.pinTextField.layer.shadowOpacity = 0.5
        
        
        self.loginButton.layer.cornerRadius = 10.0
        self.loginButton.layer.shadowColor = UIColor.black.cgColor
        self.loginButton.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        self.loginButton.layer.shadowRadius = 0.5
        self.loginButton.layer.shadowOpacity = 0.5
        

        self.loginIcon.layer.shadowColor = UIColor.black.cgColor
        self.loginIcon.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        self.loginIcon.layer.shadowRadius = 0.5
        self.loginIcon.layer.shadowOpacity = 0.5
        
        self.addDoneButtonOnKeyboard()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
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
    @objc func keyboardWillHide(notification:NSNotification) {
        self.view.layoutIfNeeded()

        UIView.animate(withDuration: 0.25, animations: {
//            self.moveBothTextFieldsUp.constant = 75.0
            self.view.layoutIfNeeded()

        })
    }
    
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


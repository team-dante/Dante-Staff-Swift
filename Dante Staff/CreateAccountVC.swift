//
//  CreateAccountVC.swift
//  Dante Staff
//
//  Created by Hung Phan on 7/20/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class CreateAccountVC: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        self.emptyValLabel.text = ""
        self.emptyValLabel.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.emptyValLabel.text = ""
        self.emptyValLabel.isHidden = true
    }

    @IBOutlet weak var emptyValLabel: UILabel!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var phoneNumTF: UITextField!
    @IBOutlet weak var pinTF: UITextField!
    @IBOutlet weak var createBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        emptyValLabel.isHidden = true
        
        self.createBtn.layer.cornerRadius = 10.0
        
        self.firstNameTF.layer.cornerRadius = 10.0

        self.lastNameTF.layer.cornerRadius = 10.0

        self.phoneNumTF.layer.cornerRadius = 10.0

        self.pinTF.layer.cornerRadius = 10.0

        
        self.addDoneButtonOnKeyboard()
    }
    
    @IBAction func createBtnPressed(_ sender: Any) {
        ViewController().showSpinner(onView: self.view)
        let opfn = self.firstNameTF.text
        let opln = self.lastNameTF.text
        let oppn = self.phoneNumTF.text
        let opp = self.pinTF.text
        
        if (!(opfn ?? "").isEmpty && !(opln ?? "").isEmpty && !(oppn ?? "").isEmpty && !(opp ?? "").isEmpty) {
                let dict : [String : String] = [
                    "firstName" : self.firstNameTF.text!,
                    "lastName" : self.lastNameTF.text!,
                    "patientPhoneNumber" : self.phoneNumTF.text!,
                    "patientPin" : self.pinTF.text!
                ]
                let email = self.phoneNumTF.text! + "@email.com"
                let password = self.pinTF.text! + "ABCDEFG"
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    // ...
                }
                Database.database().reference().child("Patients").childByAutoId()
                    .setValue(dict)
            
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    ViewController().removeSpinner()
                    self.firstNameTF.text = ""
                    self.lastNameTF.text = ""
                    self.phoneNumTF.text = ""
                    self.pinTF.text = ""
                    self.performSegue(withIdentifier: "success", sender: self)
                }
            }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                ViewController().removeSpinner()
                self.emptyValLabel.isHidden = false
                self.emptyValLabel.text = "One of the required fields is empty."
            }
        }
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
        
        firstNameTF.inputAccessoryView = doneToolbar
        lastNameTF.inputAccessoryView = doneToolbar
        phoneNumTF.inputAccessoryView = doneToolbar
        pinTF.inputAccessoryView = doneToolbar
        
    }
    
    @objc func doneButtonAction(){
        firstNameTF.resignFirstResponder()
        lastNameTF.resignFirstResponder()
        phoneNumTF.resignFirstResponder()
        pinTF.resignFirstResponder()
    }

}

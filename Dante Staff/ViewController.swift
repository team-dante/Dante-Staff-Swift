//
//  ViewController.swift
//  Dante Staff
//
//  Created by Hung Phan on 7/11/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var moveTextFieldUp: NSLayoutConstraint!
    @IBOutlet weak var loginIcon: UIImageView!
    @IBOutlet weak var loginHeader: UILabel!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var pinTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.phoneTextField.layer.cornerRadius = 10.0
        self.phoneTextField.layer.shadowColor = UIColor.black.cgColor
        self.phoneTextField.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        self.phoneTextField.layer.shadowRadius = 0.5
        self.phoneTextField.layer.shadowOpacity = 0.5
        
        
        self.pinTextField.layer.cornerRadius = 10.0
        self.pinTextField.layer.shadowColor = UIColor.black.cgColor
        self.pinTextField.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        self.pinTextField.layer.shadowRadius = 0.5
        self.pinTextField.layer.shadowOpacity = 0.5
        
        
        self.loginButton.layer.cornerRadius = 10.0
        self.loginButton.layer.shadowColor = UIColor.black.cgColor
        self.loginButton.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        self.loginButton.layer.shadowRadius = 0.5
        self.loginButton.layer.shadowOpacity = 0.5
        
        self.loginHeader.layer.shadowColor = UIColor.black.cgColor
        self.loginHeader.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        self.loginHeader.layer.shadowRadius = 0.5
        self.loginHeader.layer.shadowOpacity = 0.5

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
                    self.moveTextFieldUp.constant = 60 - offset
                    self.view.layoutIfNeeded()
    
                })
            }
        }

    }
    @objc func keyboardWillHide(notification:NSNotification) {
        self.view.layoutIfNeeded()

        UIView.animate(withDuration: 0.25, animations: {
            self.moveTextFieldUp.constant = 75.0
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


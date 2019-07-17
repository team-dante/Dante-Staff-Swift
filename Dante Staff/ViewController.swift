//
//  ViewController.swift
//  Dante Staff
//
//  Created by Hung Phan on 7/11/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var topConstraintForKeyboardAvoiding: NSLayoutConstraint!
//    var topConstraintConstant:CGFloat = 100.0
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var pinTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @objc func doneButtonAction(){
        phoneTextField.resignFirstResponder()
        pinTextField.resignFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.phoneTextField.layer.cornerRadius = 10.0
        self.pinTextField.layer.cornerRadius = 10.0
        self.loginButton.layer.cornerRadius = 10.0
        
        self.addDoneButtonOnKeyboard()
NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    @objc func keyboardWillShow(notification:NSNotification) {
            self.view.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.25, animations: {
                self.topConstraintForKeyboardAvoiding.constant = 50
                self.view.layoutIfNeeded()
                
            })
    }
    @objc func keyboardWillHide(notification:NSNotification) {
        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.25, animations: {
            self.topConstraintForKeyboardAvoiding.constant = 100
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



}


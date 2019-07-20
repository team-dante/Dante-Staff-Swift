//
//  CreateAccountVC.swift
//  Dante Staff
//
//  Created by Hung Phan on 7/20/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit

class CreateAccountVC: UIViewController {
    
    

    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var phoneNumTF: UITextField!
    @IBOutlet weak var pinTF: UITextField!
    @IBOutlet weak var createBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createBtn.layer.cornerRadius = 10.0
        self.firstNameTF.layer.cornerRadius = 10.0
        self.lastNameTF.layer.cornerRadius = 10.0
        self.phoneNumTF.layer.cornerRadius = 10.0
        self.pinTF.layer.cornerRadius = 10.0
        
        self.addDoneButtonOnKeyboard()
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

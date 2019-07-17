//
//  ViewController.swift
//  Dante Staff
//
//  Created by Hung Phan on 7/11/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var myTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.myTextField.layer.cornerRadius = 10.0
//        let paddingView = UIView(frame: CGRectMake(0, 0, 15, self.myTextField.frame.height))
    }


}


//
//  DisplayAccVC.swift
//  Dante Staff
//
//  Created by Hung Phan on 7/20/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit

class DisplayAccVC: UIViewController {

    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var phoneNum: UILabel!
    @IBOutlet weak var pin: UILabel!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var mainMenuBtn: UIButton!
    var dataReceived = ["":""]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(dataReceived)
        
        self.firstName.text = dataReceived["firstName"]
        self.lastName.text = dataReceived["lastName"]
        self.phoneNum.text = dataReceived["patientPhoneNumber"]
        self.pin.text = dataReceived["patientPin"]
    
        
        mainMenuBtn.layer.cornerRadius = 10.0
        blurView.layer.cornerRadius = 10.0
    }

}

//
//  DisplayAccVC.swift
//  Dante Staff
//
//  Created by Hung Phan on 7/20/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit

class DisplayAccVC: UIViewController {

    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var mainMenuBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        mainMenuBtn.layer.cornerRadius = 10.0
        blurView.layer.cornerRadius = 10.0
    }

}

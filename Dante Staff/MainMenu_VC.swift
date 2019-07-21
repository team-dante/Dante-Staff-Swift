//
//  MainMenu_VC.swift
//  Dante Staff
//
//  Created by Hung Phan on 7/19/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit

class MainMenu_VC: UIViewController {


    @IBOutlet weak var view1x1: UIView!
    @IBOutlet weak var view1x2: UIView!
    @IBOutlet weak var view2x1: UIView!
    @IBOutlet weak var view2x2: UIView!
    @IBOutlet weak var view3x1: UIView!
    @IBOutlet weak var view3x2: UIView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Show the Navigation Bar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        // Hide the Navigation Bar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        view1x1.layer.cornerRadius = 10.0
        view1x2.layer.cornerRadius = 10.0
        view2x1.layer.cornerRadius = 10.0
        view2x2.layer.cornerRadius = 10.0
        view3x1.layer.cornerRadius = 10.0
        view3x2.layer.cornerRadius = 10.0
        
    }


}

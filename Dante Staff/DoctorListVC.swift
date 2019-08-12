//
//  DoctorListVC.swift
//  Dante Staff
//
//  Created by Hung Phan on 7/28/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit

class DoctorListVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var legendView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        legendView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        print("TAPPED")
        print("DoctorListVC=>",BroadcastLocationViewController.GlobalVariable.fpc)
        BroadcastLocationViewController.GlobalVariable.fpc.move(to: .full, animated: true)
        
       
        
        
        
    }
}

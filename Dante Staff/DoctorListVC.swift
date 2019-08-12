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
    var full = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        legendView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
       full = !full
        if (full) {
            BroadcastLocationViewController.GlobalVariable.fpc.move(to: .full, animated: true)
        } else {
            BroadcastLocationViewController.GlobalVariable.fpc.move(to: .tip, animated: true)
        }
    }
}

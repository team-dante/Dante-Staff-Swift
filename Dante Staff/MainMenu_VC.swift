//
//  MainMenu_VC.swift
//  Dante Staff
//
//  Created by Hung Phan on 7/19/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MainMenu_VC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    var viewColor : UIColor!
    var handle: AuthStateDidChangeListenerHandle?
    var ref: DatabaseReference!
    
    @IBOutlet weak var hamburgerImage: UIImageView!
    @IBOutlet weak var view1x1: UIView!
    @IBOutlet weak var view1x2: UIView!
    @IBOutlet weak var view2x1: UIView!
    @IBOutlet weak var view2x2: UIView!
    @IBOutlet weak var view3x1: UIView!
    @IBOutlet weak var view3x2: UIView!
    @IBOutlet weak var staffLastName: UILabel!
    @IBAction func btnPressed1x1(_ sender: Any) {
        self.viewColor = self.view1x1.backgroundColor
        self.view1x1.backgroundColor = UIColor(white: 1, alpha: 0.5)
    }
    @IBAction func btnReleased1x1(_ sender: Any) {
        view.alpha = 2
        self.view1x1.backgroundColor = viewColor
        self.performSegue(withIdentifier: "goToBroadcast", sender: self)
    }
    @IBAction func dragExit1x1(_ sender: Any) {
        self.view1x1.backgroundColor = viewColor
    }
    @IBAction func btnPressed1x2(_ sender: Any) {
        self.viewColor = self.view1x2.backgroundColor
        self.view1x2.backgroundColor = UIColor(white: 1, alpha: 0.5)
    }
    @IBAction func btnReleased1x2(_ sender: Any) {
        view.alpha = 2
        self.view1x2.backgroundColor = viewColor
        self.performSegue(withIdentifier: "lookupAcc", sender: self)
    }
    
    @IBAction func dragExit1x2(_ sender: Any) {
        self.view1x2.backgroundColor = viewColor
    }
    @IBAction func btnPressed2x1(_ sender: Any) {
        self.viewColor = self.view2x1.backgroundColor
        self.view2x1.backgroundColor = UIColor(white: 1, alpha: 0.5)
    }
    @IBAction func btnReleased2x1(_ sender: Any) {
        view.alpha = 2
        self.view2x1.backgroundColor = viewColor
    }
    @IBAction func dragExit2x1(_ sender: Any) {
        self.view2x1.backgroundColor = viewColor
    }
    @IBAction func btnPressed2x2(_ sender: Any) {
        self.viewColor = self.view2x2.backgroundColor
        self.view2x2.backgroundColor = UIColor(white: 1, alpha: 0.5)
    }
    @IBAction func btnReleased2x2(_ sender: Any) {
        view.alpha = 2
        self.view2x2.backgroundColor = viewColor
    }
    
    @IBAction func dragExit2x2(_ sender: Any) {
        self.view2x2.backgroundColor = viewColor
    }
    @IBAction func btnPressed3x1(_ sender: Any) {
        self.viewColor = self.view3x1.backgroundColor
        self.view3x1.backgroundColor = UIColor(white: 1, alpha: 0.5)
    }
    @IBAction func btnReleased3x1(_ sender: Any) {
        view.alpha = 2
        self.view3x1.backgroundColor = viewColor
        self.performSegue(withIdentifier: "createAcc", sender: self)
    }
    
    @IBAction func dragExit3x1(_ sender: Any) {
        self.view3x1.backgroundColor = viewColor
    }
    @IBAction func btnPressed3x2(_ sender: Any) {
        self.viewColor = self.view3x2.backgroundColor
        self.view3x2.backgroundColor = UIColor(white: 1, alpha: 0.5)
    }
    @IBAction func btnReleased3x2(_ sender: Any) {
        view.alpha = 2
        self.view3x2.backgroundColor = viewColor
        try! Auth.auth().signOut()
        //        let user = Auth.auth().currentUser
        self.performSegue(withIdentifier: "signout", sender: self)
    }

    @IBAction func dragExit3x2(_ sender: Any) {
        self.view3x2.backgroundColor = viewColor
    }
    
    
    @IBAction func openCameraBtn(_ sender: UIButton) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: false, completion: nil)
        }
        
    }
    
    @IBAction func drawerBtnPressed(_ sender: Any) {
        self.hamburgerImage.image = UIImage(named: "hamburger-pressed-black")
    }
    
    @IBAction func drawerBtnReleased(_ sender: Any) {
        self.hamburgerImage.image = UIImage(named: "hamburger-icon")
    }
    
    @IBAction func dragExitDrawerBtn(_ sender: Any) {
        self.hamburgerImage.image = UIImage(named: "hamburger-icon")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Show the Navigation Bar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = Auth.auth().currentUser {
                let phoneNum = user.email!.split(separator: "@")[0]
                Database.database().reference().child("staffs").observeSingleEvent(of: .value, with: { (snapshot) in
                    for eachDoctor in snapshot.children.allObjects as! [DataSnapshot] {
                        let dict = eachDoctor.value as? [String : String] ?? [:]
                        if (String(dict["phoneNum"]!) == String(phoneNum)) {
                            self.staffLastName.text = "Welcome, Staff \(dict["lastName"] ?? "")"
                        }
                    }
                }) { (error) in
                    print("=====>", error.localizedDescription)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        // Hide the Navigation Bar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        // detach listener
        Auth.auth().removeStateDidChangeListener(handle!)
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


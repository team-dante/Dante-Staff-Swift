//
//  NewBroadcastLocationViewController.swift
//  Dante Staff
//
//  Created by Hung Phan on 9/12/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit
import KontaktSDK
import Firebase
import FirebaseAuth
import FloatingPanel
import NVActivityIndicatorView

class NewBroadcastLocationViewController: UIViewController, UIScrollViewDelegate, FloatingPanelControllerDelegate {
    
    @IBOutlet weak var scrollViewContent: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var bottomView: UIView!
    var fpc : FloatingPanelController!
    var staffVC : StaffPinViewController!
    var beaconManager : KTKBeaconManager!
    var region : KTKBeaconRegion!
    var ref: DatabaseReference!
    var staffPhoneNumber : String!
    // an array of dictionary with both key and value are String.
    var staffs = [[String:String]]()
    var mapDict : [String: [(Double, Double)]] = [
        "LA1" : [(158, 352), (185, 370)],
        "TLA" : [(361, 269), (390, 207)],
        "CT" : [(15, 421), (50, 427)],
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.topItem!.title = "Stop"
        
        staffPhoneNumber = String((Auth.auth().currentUser?.email?.split(separator: "@")[0] ?? "N/A"))
        
        // Initialize FloatingPanelController
        fpc = FloatingPanelController()
        fpc.delegate = self
        
        // Initialize FloatingPanelController and add the view
        // Initialize FloatingPanelController and add the view
        fpc.surfaceView.backgroundColor = UIColor(displayP3Red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0, alpha: 1.0)
        fpc.surfaceView.cornerRadius = 24.0
        fpc.surfaceView.shadowHidden = true
        fpc.surfaceView.borderWidth = 1.0 / traitCollection.displayScale
        fpc.surfaceView.borderColor = UIColor.black.withAlphaComponent(0.2)
        
        staffVC = storyboard?.instantiateViewController(withIdentifier: "StaffList") as? StaffPinViewController
        
        // Set a content view controller
        fpc.set(contentViewController: staffVC)
        fpc.track(scrollView: staffVC.tableView)
        
        // tap on surface to trigger events
        let surfaceTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSurface(tapGesture:)))
        fpc.surfaceView.addGestureRecognizer(surfaceTapGesture)
        
        fpc.addPanel(toParent: self, belowView: bottomView, animated: false)
        
        // used for zooming imageView
        scrollViewContent.delegate = self
        
        // get user pin color
        
        if UIScreen.main.bounds.width == 414 {
            imageView.image = UIImage(named: "clinic-map-414")
        } else if UIScreen.main.bounds.width == 375 {
            imageView.image = UIImage(named: "clinic-map-375")
        }
        
        let circleLayer414 = CAShapeLayer()
        let circleLayer375 = CAShapeLayer()
        
        let ratio_of_414_to_375 = 1.104
        let x414 = 27.0
        let y414 = 357.0
        let width414 = 10.0
        let height414 = 10.0
        
        if UIScreen.main.bounds.width == 414 {
            circleLayer414.path = UIBezierPath(ovalIn: CGRect(x: x414, y: y414, width: width414, height: height414)).cgPath
            circleLayer414.fillColor = UIColor(red: 255/255, green: 220/255, blue: 36/255, alpha: 1.0).cgColor
            circleLayer414.strokeColor = UIColor.white.cgColor
        } else if UIScreen.main.bounds.width == 375 {
            circleLayer375.path = UIBezierPath(ovalIn: CGRect(x: (x414/ratio_of_414_to_375), y: y414, width: (width414/ratio_of_414_to_375), height: (height414/ratio_of_414_to_375))).cgPath
            circleLayer375.fillColor = UIColor(red: 255/255, green: 220/255, blue: 36/255, alpha: 1.0).cgColor
            circleLayer375.strokeColor = UIColor.white.cgColor
        }
        
        self.imageView.layer.addSublayer(circleLayer414)
        self.imageView.layer.addSublayer(circleLayer375)
        
    }
    
    // if FloatingPanel's position is at tip, then it will be at half
    @objc func handleSurface(tapGesture: UITapGestureRecognizer) {
        if fpc.position == .tip {
            fpc.move(to: .full, animated: true)
        } else if fpc.position == .full {
            fpc.move(to: .tip, animated: true)
        } else if fpc.position == .half {
            fpc.move(to: .full, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // change the default floatingPanel layout. Modification is in class StaffFloatingPanelLayout: FloatingPanelLayout
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        // called the approriate class name when modifying the floating panel layout
        return StaffFloatingPanelLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        if self.navigationController?.viewControllers.firstIndex(of: self) == nil {
            // Back button pressed because self is no longer in the navigation stack.
            // Stop ranging if needed
//            beaconManager.stopRangingBeacons(in: region)
        }
    }
}

class StaffFloatingPanelLayout: FloatingPanelLayout {
    
    public var initialPosition: FloatingPanelPosition {
        return .tip
    }
    
    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 16.0 // A top inset from safe area
        case .half: return UIScreen.main.bounds.height / 2.0 // A bottom inset from the safe area
        case .tip:
            let height = UIScreen.main.bounds.height
            if height == 896.0 { // iPhone 11 Pro Max
                return 250.0
            } else if height == 812.0 { // iPhone 11 Pro
                return 150.0
            } else if height == 736.0 { // iPhone 8 Plus
                return 130.0
            } else if height == 667.0 { // iPhone 8
                return 90.0
            }
        default: return nil // Or case .hidden: return nil
        }
        return nil
    }
}

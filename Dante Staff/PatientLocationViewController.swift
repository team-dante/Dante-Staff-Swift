//
//  ViewController.swift
//  Dante Patient
//
//  Created by Xinhao Liang on 7/1/19.
//  Updated by Hung Phan on 9/12/19
//  Copyright © 2019 Xinhao Liang. All rights reserved.
//
import UIKit
import Firebase
import FloatingPanel

class PatientLocationViewController: UIViewController, UIScrollViewDelegate, FloatingPanelControllerDelegate {
    
    var fpc: FloatingPanelController!
    var pinRef: PatientPinViewController!
    var ref: DatabaseReference!
    var allLayers = [String:[CAShapeLayer]]()
    let ratio_of_414_to_375 = 1.104
    let circlePinWidth414 = 10.0
    let circlePinHeight414 = 10.0

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mapUIView: UIView!
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    
    var mapDict: [String: [(Double, Double)]] = [
        "LA1": [
            (152,335), (165,327), (183,327), (148,364), (172,354),
            (195,354), (148,381), (177,387), (180,370), (194,401),
            (149,424), (170,424), (188,426), (148,455), (179,449)
        ],
        "TLA": [
            (388,255), (353,259), (370,257), (341,276), (363,283),
            (387,282), (355,309), (381,305), (339,185), (365,181),
            (390,179), (337,202), (370,216), (396,215), (352,346)
        ],
        "CT": [
            (36,325), (51,325), (60,335), (45,339), (60,350),
            (37,357), (5,369), (31,369), (53,371), (45,383),
            (62,395), (5,411), (33,409), (55,410), (31,425)
        ],
        "WR": [
            (111,5), (123,5), (136,4), (111,17), (125,17),
            (137,18), (111,52), (123,39), (136,39), (111,38),
            (123,52), (136,52), (111,65), (123,65), (136,65)
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // connecting to Firebase initially
        ref = Database.database().reference()
        
        // --------------- settting up FloatingPanel ------------------
        // init FloatingPanelController
        fpc = FloatingPanelController()
        fpc.delegate = self
        
        // Initialize FloatingPanelController and add the view
        fpc.surfaceView.backgroundColor = .clear
        fpc.surfaceView.cornerRadius = 24.0
        fpc.surfaceView.shadowHidden = true
        
        pinRef = storyboard?.instantiateViewController(withIdentifier: "PatientPinViewController") as? PatientPinViewController
        
        // insert ViewController into FloatingPanel
        fpc.set(contentViewController: pinRef)
        fpc.track(scrollView: pinRef.tableView)
        
        // tap on surface to trigger events
        let surfaceTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSurface(tapGesture:)))
        fpc.surfaceView.addGestureRecognizer(surfaceTapGesture)
        
        //  Add FloatingPanel to a view with animation.
        fpc.addPanel(toParent: self, animated: true)
        
        // --------------- Done setting up FloatingPanel ------------------
        
        // zoom in/out effect
        self.scrollView.delegate = self
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 4.0
        
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // call observe to always listen for event changes
        ref.child("PatientLocation").observe(.value, with: {(snapshot) in
            if let patients = snapshot.value as? [String: Any] {
                for patient in patients {
                    let key = patient.key

                    if let pat = patient.value as? [String: String] {
                        let room = pat["room"]! // e.g. "CTRoom"
                        if room != "Private" {
                            let color = pat["pinColor"]!
                            
                            // remove the old pin before drawing the new pin
                            self.removePin(key: key)
                            
                            // drawing the staff to the newest location
                            self.updatePatLoc(patient: key, color: color, x: self.mapDict[room]![0].0, y: self.mapDict[room]![0].1)
                            
                            // recycle pin positions
                            let firstElement = self.mapDict[room]!.remove(at: 0)
                            self.mapDict[room]!.append(firstElement)
                            
                        } else {
                            // remove the old pin before being "invisible"
                            self.removePin(key: key)
                        }
                    }
                }
            }
        })
    }
    
    // delegate method to help zooming
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.mapUIView
    }
    
    // remove staff's pin
    func removePin(key: String) {
        // allLayers serve to record all pin layers
        if let val = self.allLayers[key] {
            // remove pin (circle + rect); remove from array
            val.forEach({
                $0.removeFromSuperlayer()
                print("removedLayer====>", $0.name!)
            })
            self.allLayers.removeValue(forKey: key)
        }
    }
    
    // utilize offsets; add pat pin(UIImage) to UIView
    func updatePatLoc(patient: String, color: String, x: Double, y: Double) {
        // parse color rgb (e.g. "222-08-10")
        let rgb = color.split(separator: "-")
        let r = CGFloat(Int(rgb[0])!)
        let g = CGFloat(Int(rgb[1])!)
        let b = CGFloat(Int(rgb[2])!)
        
        let circleLayer414 = CAShapeLayer()
        let circleLayer375 = CAShapeLayer()
        
        let x414 = x
        let y414 = y
        
        let x375 = x414/self.ratio_of_414_to_375
        let y375 = y414
        
        if UIScreen.main.bounds.width == 414 {
            circleLayer414.path = UIBezierPath(ovalIn: CGRect(x: x414, y: y414, width: self.circlePinWidth414, height: self.circlePinHeight414)).cgPath
            circleLayer414.fillColor = UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1.0).cgColor
            circleLayer414.strokeColor = UIColor.white.cgColor
            
            circleLayer414.name = "\(x414)-\(y414)->\(patient)"
            self.mapUIView.layer.addSublayer(circleLayer414)
            // each patient pin is represented by a circle and a rectangle
            self.allLayers[patient] = [circleLayer414]

            
        } else if UIScreen.main.bounds.width == 375 {
            circleLayer375.path = UIBezierPath(ovalIn: CGRect(x: x375, y: y375, width: (self.circlePinWidth414/self.ratio_of_414_to_375), height: (self.circlePinHeight414/self.ratio_of_414_to_375))).cgPath
            circleLayer375.fillColor = UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1.0).cgColor
            circleLayer375.strokeColor = UIColor.white.cgColor
            
            circleLayer414.name = "\(x375)-\(y375)->\(patient)"
            self.mapUIView.layer.addSublayer(circleLayer375)
            // each patient pin is represented by a circle and a rectangle
            self.allLayers[patient] = [circleLayer375]

        }
        
    }
    
    // change the default floatingPanel layout
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return MyFloatingPanelLayout()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // to avoid memory leaks
        ref.removeAllObservers()
    }
}

class MyFloatingPanelLayout: FloatingPanelLayout {
    
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
                return 170.0
            } else if height == 736.0 { // iPhone 8 Plus
                return 150.0
            } else if height == 667.0 { // iPhone 8
                return 90.0
            }
        default: return nil // Or case .hidden: return nil
        }
        return nil
    }
}

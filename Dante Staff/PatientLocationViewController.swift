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

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mapUIView: UIView!
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    
    var mapDict: [String: [(Double, Double)]] = [
        "LA1": [(0.38, 0.7), (0.41, 0.75), (0.46, 0.75), (0.48, 0.7), (0.39, 0.8)],
        "TLA": [(0.9, 0.36), (0.95, 0.5), (0.83, 0.54), (0.8, 0.5), (0.86, 0.4)],
        "CT": [(0.09, 0.7), (0.03, 0.75), (0.12, 0.75), (0.06, 0.7), (0.04, 0.8)],
        "WR": [(0.27, 0.41), (0.3, 0.41), (0.27, 0.47), (0.31, 0.47), (0.33, 0.45)]
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
            val.forEach({ $0.removeFromSuperlayer() })
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
        
        // coords.0: x in pixels; coords.1: y in pixels; coords.2: width; coords.3: total height of pin shape
        let coords = self.pinCoords(propX: x, propY: y, propW: 10/375.0, propH: 23/450.0)
        
        // circle: same width and height
        let circleLayer = CAShapeLayer()
        circleLayer.path = UIBezierPath(ovalIn: CGRect(x: coords.0, y: coords.1, width: coords.2, height: coords.2)).cgPath
        circleLayer.fillColor = UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1.0).cgColor
        circleLayer.strokeColor = UIColor.white.cgColor
        
        // pin stand: right under the circle, has width of 4, height = total height - circle height
//        let rectLayer = CAShapeLayer()
//        rectLayer.path = UIBezierPath(rect: CGRect(x: coords.0 + coords.2 / 2.0 - 1.0, y: coords.1 + coords.2, width: 2, height: coords.3 - coords.2)).cgPath
//        rectLayer.fillColor = UIColor.white.cgColor
        
        self.mapUIView.layer.addSublayer(circleLayer)
//        self.mapUIView.layer.addSublayer(rectLayer)
        
        // each patient pin is represented by a circle and a rectangle
        self.allLayers[patient] = [circleLayer]
    }
    
    // change the default floatingPanel layout
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return MyFloatingPanelLayout()
    }
    
    func pinCoords(propX: Double, propY: Double, propW: Double, propH: Double) -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        var w: CGFloat = 0.0
        var h: CGFloat = 0.0
        
        let deviceWidth = self.view.frame.width
        let deviceHeight = self.mapUIView.frame.height
        
        // the width:height proportion of the map is 0.8333:1
        let propHeight = deviceWidth / 0.8333
        
        // if proportional height is less than the actual height that the device gives to the map, add y-offset
        // otherwise, add x-offset
        if propHeight < deviceHeight {
            let yAxisOffset = (deviceHeight - propHeight)/CGFloat(2.0)
            x = deviceWidth * CGFloat(propX)
            y = propHeight * CGFloat(propY) + yAxisOffset
            w = deviceWidth * CGFloat(propW)
            h = propHeight * CGFloat(propH)
        } else {
            let propWidth = deviceHeight * CGFloat(0.8333)
            let xAxisOffset = (deviceWidth - propWidth)/CGFloat(2.0)
            x = propWidth * CGFloat(propX) + xAxisOffset
            y = deviceHeight * CGFloat(propY)
            w = propWidth * CGFloat(propW)
            h = deviceHeight * CGFloat(propH)
        }
        // return a 4-elem tuple
        return (x, y, w, h)
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
                return 140.0
            } else if height == 736.0 { // iPhone 8 Plus
                return 120.0
            } else if height == 667.0 { // iPhone 8
                return 100.0
            }
        default: return nil // Or case .hidden: return nil
        }
        return nil
    }
}

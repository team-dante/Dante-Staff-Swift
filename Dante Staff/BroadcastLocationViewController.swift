//
//  BroadcastLocationViewController.swift
//  Dante Staff
//
//  Created by Hung Phan on 7/24/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit
import KontaktSDK
import Firebase
import FirebaseAuth
import FloatingPanel
import NVActivityIndicatorView

class BroadcastLocationViewController: UIViewController, UIScrollViewDelegate, FloatingPanelControllerDelegate {
    
    var fpc : FloatingPanelController!
    var doctorVC : DoctorListVC!
    
    var beaconManager: KTKBeaconManager!
    var region: KTKBeaconRegion!
    var userPhoneNum : String?
    // records a queue of 10 distances for each beacon
    var roomDict: [Int: [Double]] = [1: [], 2: [], 3:[]]
    // map beacon major to the real clinic room
    let majorToRoom = [ 1: "CT Simulator", 2: "Linear Accelerator 1", 3: "Trilogy Linear Accelerator" ]
    // map beacon major to its corresponding cutoff value (1m)
    let cutoff = [1: 1.5, 2: 1.5, 3: 1.5]
    // after 10 rounds, perform stats analysis
    let threshold = 5
    var count = 0
    var currRoom = ""
    
    @IBOutlet weak var uciImageView: UIImageView!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var descriptionView: UIView!
    var descriptionFrameActivityIndicatorView : NVActivityIndicatorView!
    var mapFrameActivityIndicatorView : NVActivityIndicatorView!
    var descriptionFrame : CGRect!
    var mapFrame : CGRect!
    
    let pinColor = ["111" : 1,
                    "222" : 2,
                    "333" : 3,
                    "444" : 4,
                    "555" : 5,
                    "666" : 6,
                    "777" : 7,
                    "888" : 8,
                    "999" : 9,
                    "1000" : 10]
    
    @IBOutlet weak var ctsView: UIView!
    @IBOutlet weak var tlaView: UIView!
    @IBOutlet weak var la1View: UIView!

    @IBOutlet weak var timeTickingLabel: UILabel!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var scrollViewContent: UIScrollView!
    @IBOutlet weak var flashImageView: UIView!
    
    @IBOutlet weak var userPinColor: UIImageView!
    @IBOutlet weak var pinView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideAllPins()
        
        // animating the description frame
        descriptionFrame = CGRect(x: self.descriptionView.bounds.origin.x, y: self.descriptionView.bounds.origin.y, width: self.descriptionView.bounds.size.width, height: self.descriptionView.bounds.size.height)
        descriptionFrameActivityIndicatorView = NVActivityIndicatorView(frame: descriptionFrame, type: .lineScale, padding: 10)
        self.descriptionView.addSubview(descriptionFrameActivityIndicatorView)
        descriptionFrameActivityIndicatorView.startAnimating()
        self.timeTickingLabel.isHidden = true

        // animating the map frame
        mapFrame = CGRect(x: self.mapView.bounds.origin.x, y: self.mapView.bounds.origin.y, width: self.mapView.bounds.size.width, height: self.mapView.bounds.size.height)
        mapFrameActivityIndicatorView = NVActivityIndicatorView(frame: mapFrame, type: .ballClipRotate, padding: 300)
        self.mapView.addSubview(mapFrameActivityIndicatorView)
        mapFrameActivityIndicatorView.startAnimating()
        self.uciImageView.isHidden = true


        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            self.descriptionFrameActivityIndicatorView.stopAnimating()
            self.descriptionFrameActivityIndicatorView.removeFromSuperview()
            self.timeTickingLabel.isHidden = false
            self.mapFrameActivityIndicatorView.stopAnimating()
            self.mapFrameActivityIndicatorView.removeFromSuperview()
            self.uciImageView.isHidden = false
        }
        
        // Initialize FloatingPanelController
        fpc = FloatingPanelController()
        fpc.delegate = self
        
        // Initialize FloatingPanelController and add the view
        fpc.surfaceView.backgroundColor = UIColor(displayP3Red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0, alpha: 1.0)
        fpc.surfaceView.cornerRadius = 24.0
        fpc.surfaceView.shadowHidden = true
        fpc.surfaceView.borderWidth = 1.0 / traitCollection.displayScale
        fpc.surfaceView.borderColor = UIColor.black.withAlphaComponent(0.2)
        
        doctorVC = storyboard?.instantiateViewController(withIdentifier: "DoctorList") as? DoctorListVC
        
        // Set a content view controller
        fpc.set(contentViewController: doctorVC)
        fpc.track(scrollView: doctorVC.scrollView)
        
        fpc.addPanel(toParent: self, belowView: bottomView, animated: false)
        
        fpc.move(to: .tip, animated: true)
        
        Database.database().reference().child("StaffLocation").observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String: AnyObject] ?? [:]
            
            self.hideAllPins()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.flashImageView.backgroundColor = UIColor(displayP3Red: 0.100, green: 0.100, blue: 0.100, alpha: 0.1)
            }
            self.flashImageView.backgroundColor = UIColor(white: 1, alpha: 0.3)
            
            for (key , value) in postDict {
                let roomString : String = (value["room"] as? String)!
                
                if (roomString == "Linear Accelerator 1") {
                    
                    let iTag = self.pinColor[key]
                    print("linear accelerator 1 ==> ", iTag!)
                    self.la1View.viewWithTag(iTag!)!.isHidden = false
                }
                else if (roomString == "CT Simulator") {
                    let iTag = self.pinColor[key]
                    print("CT Simulator ==> ", iTag!)
                    self.ctsView.viewWithTag(iTag!)!.isHidden = false
                }
                else if (roomString == "Trilogy Linear Accelerator") {
                    let iTag = self.pinColor[key]
                    print(iTag!)
                    self.tlaView.viewWithTag(iTag!)!.isHidden = false
                }
                else if (roomString == "Private") {
                    let iTag = self.pinColor[key]
                    print("private ==> ", iTag!)
                    self.la1View.viewWithTag(iTag!)!.isHidden = true
                    self.ctsView.viewWithTag(iTag!)!.isHidden = true
                    self.tlaView.viewWithTag(iTag!)!.isHidden = true
                }
            }
        })
        
        // used for zooming imageView
        scrollViewContent.delegate = self
        
        //        self.timeTickingLabel.text = "Beacons detected. You are in Female Waiting Room"
        
        userPhoneNum = String((Auth.auth().currentUser?.email?.split(separator: "@")[0] ?? ""))

        userPinColor.image = UIImage(named: "test" + String(pinColor[userPhoneNum!]!))
        
        Kontakt.setAPIKey("IKLlxikqjxJwiXbyAgokGeLkcZqipAnc")
        
        // Initialize Beacon Manager
        beaconManager = KTKBeaconManager(delegate: self)
        beaconManager.requestLocationAlwaysAuthorization()
        
        // Create Beacon Region
        region = KTKBeaconRegion(proximityUUID: UUID(uuidString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")!, identifier: "region-identifier")
        
        beaconManager.startRangingBeacons(in: region)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideAllPins()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        if self.navigationController?.viewControllers.firstIndex(of: self) == nil {
            // Back button pressed because self is no longer in the navigation stack.
            // Stop ranging if needed
            beaconManager.stopRangingBeacons(in: region)
            
            if (userPhoneNum != "445566") {
                Database.database().reference().child("/StaffLocation/\(userPhoneNum!)/room").setValue("Private")
            }
        }
        super.viewWillDisappear(animated)
    }
    
    // return flashImageView when zooming
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return flashImageView
    }
    
    func hideAllPins() {
        
        for i in 1...10 {
            self.la1View.viewWithTag(i)!.isHidden = true
        }
        
        for i in 1...10 {
            self.ctsView.viewWithTag(i)!.isHidden = true
        }
        
        for i in 1...10 {
            self.tlaView.viewWithTag(i)!.isHidden = true
        }
        
    }
    
    
    //    func prettifyRoom(room: String) -> String {
    //        switch room {
    //        case "femaleWaitingRoom":
    //            return "CT Simulator"
    //        case "CTRoom":
    //            return "CT Room"
    //        case "exam1":
    //            return "Exam 1 Room"
    //        default:
    //            return ""
    //        }
    //    }
}

extension BroadcastLocationViewController: KTKBeaconManagerDelegate {
    
    func beaconManager(_ manager: KTKBeaconManager, didRangeBeacons beacons: [CLBeacon], in region: KTKBeaconRegion) {
        
        // Debugging purposes
        for beacon in beacons {
            print(beacon.major, beacon.accuracy)
        }
        
        // wait a few rounds (5) to gather data to compute avg
        if (self.count < self.threshold) {
            self.count += 1
            
            
            for beacon in beacons {
                // if too far, assume 999m away
                if beacon.accuracy == -1 {
                    self.roomDict[Int(truncating: beacon.major)]?.append(999)
                } else {
                    self.roomDict[Int(truncating: beacon.major)]?.append(Double(beacon.accuracy))
                }
            }
        } else {
            
            for beacon in beacons {
                // queue system; dequeue iff array length >= threshold
                if self.roomDict[Int(truncating: beacon.major)]!.count >= threshold {
                    self.roomDict[Int(truncating: beacon.major)]?.remove(at: 0)
                }
                if beacon.accuracy == -1 {
                    self.roomDict[Int(truncating: beacon.major)]?.append(999)
                } else {
                    self.roomDict[Int(truncating: beacon.major)]?.append(Double(beacon.accuracy))
                }
            }
            // compute avg of the recent 5 results
            var avgList: [Int: Double] = [:]
            for beacon in beacons {
                let beaconArray = self.roomDict[Int(truncating: beacon.major)]
                if beaconArray!.count >= threshold {
                    let avg = Double(beaconArray!.reduce(0, +)) / Double(threshold)
                    avgList[Int(truncating: beacon.major)] = avg
                }
            }
            // sort beacons by avg; [Int:Double] -> [(key: ..., value:...)]
            let sortedBeaconArr = avgList.sorted(by: { $0.1 < $1.1})
            
            // if no beacons are detected or the distance of the nearest beacon is greater than the cutoff,
            //      set currRoom to Private
            if sortedBeaconArr.count != 0 {
                if sortedBeaconArr[0].value >= self.cutoff[sortedBeaconArr[0].key]! {
                    self.currRoom = "Private"
                Database.database().reference().child("/StaffLocation/\(userPhoneNum!)/room").setValue("Private")

                    self.timeTickingLabel.text = "No beacons detected nearby. Your location is currently private."
                    
                    
                } else {
                    self.currRoom = self.majorToRoom[sortedBeaconArr[0].key]!
                        
                        self.timeTickingLabel.text = "Beacons detected. You are in \(currRoom)"
                        
                        Database.database().reference().child("/StaffLocation/\(userPhoneNum!)").updateChildValues(["room" : currRoom])
                }
            } else {
                self.currRoom = "Private"
            Database.database().reference().child("/StaffLocation/\(userPhoneNum!)/room").setValue("Private")
                self.timeTickingLabel.text = "No beacons detected nearby. Your location is currently private."
                
            }
        }
        
    }
}

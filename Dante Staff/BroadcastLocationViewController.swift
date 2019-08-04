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

class BroadcastLocationViewController: UIViewController, UIScrollViewDelegate, FloatingPanelControllerDelegate {
    
    var fpc : FloatingPanelController!
    var doctorVC : DoctorListVC!
    
    var beaconManager: KTKBeaconManager!
    var region: KTKBeaconRegion!
    var userPhoneNum : String?
    // records a queue of 10 distances for each beacon
    var roomDict: [Int: [Double]] = [1: [], 2: [], 3:[]]
    // map beacon major to the real clinic room
    let majorToRoom = [ 1: "exam1", 2: "CTRoom", 3: "femaleWaitingRoom" ]
    // map beacon major to its corresponding cutoff value (1m)
    let cutoff = [1: 1.5, 2: 1.5, 3: 1.5]
    // after 10 rounds, perform stats analysis
    let threshold = 5
    var count = 0
    var currRoom = ""
    var counting = 6
    let pinColor = ["111" : "yellow-pin", "222" : "green-pin"]
    var findPinRoom : [String : UIView] = [:]
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var timeTickingLabel: UILabel!
    @IBOutlet weak var scrollViewContent: UIScrollView!
    @IBOutlet weak var imageView: UIView!
    
    @IBOutlet weak var ctYellow: UIView!
    @IBOutlet weak var ctGreen: UIView!
    @IBOutlet weak var fwrYellow: UIView!
    @IBOutlet weak var fwrGreen: UIView!
    @IBOutlet weak var e1Green: UIView!
    @IBOutlet weak var e1Yellow: UIView!
    @IBOutlet weak var flashImageView: UIView!
    @IBOutlet weak var userPinColor: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideAllPins()
        
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
        
        
        findPinRoom = ["exam1-111"  : e1Yellow,
                       "exam1-222"   : e1Green,
                       "CTRoom-111" : ctYellow,
                       "CTRoom-222"  : ctGreen,
                       "femaleWaitingRoom-111" : fwrYellow,
                       "femaleWaitingRoom-222"  : fwrGreen]
        
        Database.database().reference().child("DoctorLocation").observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String: AnyObject] ?? [:]
        
            self.hideAllPins()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.flashImageView.backgroundColor = UIColor(displayP3Red: 0.100, green: 0.100, blue: 0.100, alpha: 0.1)
            }
            self.flashImageView.backgroundColor = UIColor(white: 1, alpha: 0.3)

            
            for (key, value) in postDict {
                var valueString : String = (value["room"] as? String)!
                var pinColor : String = ""

                if (valueString != "Private") {
                    pinColor = valueString + "-" + key
                    self.findPinRoom[pinColor]?.isHidden = false
                }
                else if (valueString == "Private") {
                    pinColor = valueString + "-" + key
                    self.findPinRoom[pinColor]?.isHidden = true
                }
            }
        })
        
        // used for zooming imageView
        scrollViewContent.delegate = self
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
        
//        self.timeTickingLabel.text = "Beacons detected. You are in Female Waiting Room"
        
        userPhoneNum = String((Auth.auth().currentUser?.email?.split(separator: "@")[0] ?? ""))
        if (userPhoneNum != "445566") {
            userPinColor.image = UIImage(named: pinColor[userPhoneNum!]!)
        }
        
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
                
//                 flashFirst5 = false
//                 flashOnceWhenAppear = false
//                 flashOnceWhenDisappear = false
              Database.database().reference().child("/DoctorLocation/\(userPhoneNum!)/room").setValue("Private")
            }
        }
        super.viewWillDisappear(animated)
    }
    
    // return imageView when zooming
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func hideAllPins() {
        ctYellow.isHidden = true
        ctGreen.isHidden = true
        fwrYellow.isHidden = true
        fwrGreen.isHidden = true
        e1Green.isHidden = true
        e1Yellow.isHidden = true
    }
    
    
    func prettifyRoom(room: String) -> String {
        switch room {
        case "femaleWaitingRoom":
            return "Female Waiting Room"
        case "CTRoom":
            return "CT Room"
        case "exam1":
            return "Exam 1 Room"
        default:
            return ""
        }
    }
}

//var flashFirst5 = false
//var flashOnceWhenAppear = false
//var flashOnceWhenDisappear = false
//var prevRoom = ""
extension BroadcastLocationViewController: KTKBeaconManagerDelegate {
    
    func beaconManager(_ manager: KTKBeaconManager, didRangeBeacons beacons: [CLBeacon], in region: KTKBeaconRegion) {
        
        // Debugging purposes
        for beacon in beacons {
            print(beacon.major, beacon.accuracy)
        }
        
        // wait a few rounds (5) to gather data to compute avg
        if (self.count < self.threshold) {
            self.count += 1
            
            self.counting -= 1

            self.timeTickingLabel.text = "Initiate Location Tracking in \(counting)"
            
            for beacon in beacons {
                // if too far, assume 999m away
                if beacon.accuracy == -1 {
                    self.roomDict[Int(truncating: beacon.major)]?.append(999)
                } else {
                    self.roomDict[Int(truncating: beacon.major)]?.append(Double(beacon.accuracy))
                }
            }
        } else {
//            if (!flashFirst5){
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                    self.flashImageView.backgroundColor = UIColor(displayP3Red: 0.100, green: 0.100, blue: 0.100, alpha: 0.1)
//                }
//                self.flashImageView.backgroundColor = UIColor(white: 1, alpha: 0.3)
//                flashFirst5 = true
//            }
            
            
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
//                    if (flashOnceWhenAppear && !flashOnceWhenDisappear) {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                            self.flashImageView.backgroundColor = UIColor(displayP3Red: 0.100, green: 0.100, blue: 0.100, alpha: 0.1)
//                        }
//                        self.flashImageView.backgroundColor = UIColor(white: 1, alpha: 0.3)
//                        flashOnceWhenAppear = false
//                        flashOnceWhenDisappear = true
//                    }
                    if (userPhoneNum != "445566") {
                        Database.database().reference().child("/DoctorLocation/\(userPhoneNum!)/room").setValue("Private")
                    }
                    self.timeTickingLabel.text = "No beacons detected nearby. Your location is currently private."
                    
//                    hideAllPins()

                } else {
                    self.currRoom = self.majorToRoom[sortedBeaconArr[0].key]!
                   
                    if (userPhoneNum != "445566") {
//                        if (!flashOnceWhenAppear) {
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                                self.flashImageView.backgroundColor = UIColor(displayP3Red: 0.100, green: 0.100, blue: 0.100, alpha: 0.1)
//                            }
//                            self.flashImageView.backgroundColor = UIColor(white: 1, alpha: 0.3)
//                            flashOnceWhenAppear = true
//                        }
                        self.timeTickingLabel.text = "Beacons detected. You are in \(prettifyRoom(room: currRoom))"
                        
                        
//                        if (prevRoom == "") {
//                            prevRoom = currRoom + "-" + userPinColor
//                            findPinRoom[currRoom + "-" + userPinColor]?.isHidden = false
//                        }
//                        else {
//                            findPinRoom[prevRoom]?.isHidden = true
//                            findPinRoom[currRoom + "-" + userPinColor]?.isHidden = false
//                            prevRoom = currRoom + "-" + userPinColor
//                        }
                        Database.database().reference().child("/DoctorLocation/\(userPhoneNum!)").updateChildValues(["room" : currRoom])
                    }
                }
            } else {
                self.currRoom = "Private"
//                hideAllPins()
//                if (flashOnceWhenAppear && !flashOnceWhenDisappear) {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                        self.flashImageView.backgroundColor = UIColor(displayP3Red: 0.100, green: 0.100, blue: 0.100, alpha: 0.1)
//                    }
//                    self.flashImageView.backgroundColor = UIColor(white: 1, alpha: 0.3)
//                    flashOnceWhenAppear = false
//                    flashOnceWhenDisappear = true
//                }
                if (userPhoneNum != "445566") {
                    Database.database().reference().child("/DoctorLocation/\(userPhoneNum!)/room").setValue("Private")
                }
                self.timeTickingLabel.text = "No beacons detected nearby. Your location is currently private."

            }
    }
    
}
}

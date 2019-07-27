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

class BroadcastLocationViewController: UIViewController, UIScrollViewDelegate {
    
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
    let pinColor = ["111" : "yellow", "222" : "green"]
    var findPinRoom : [String : UIView] = [:]
    var userPinColor = ""
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideAllPins()
        
        findPinRoom = ["exam1-yellow"  : e1Yellow,
                       "exam1-green"   : e1Green,
                       "CTRoom-yellow" : ctYellow,
                       "CTRoom-green"  : ctGreen,
                       "femaleWaitingRoom-yellow" : fwrYellow,
                       "femaleWaitingRoom-green"  : fwrGreen]
        
        // used for zooming imageView
        scrollViewContent.delegate = self
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
        
//        self.roomLabel.text = prettifyRoom(room: "femaleWaitingRoom")
        
        userPhoneNum = String((Auth.auth().currentUser?.email?.split(separator: "@")[0] ?? ""))
        if (userPhoneNum != "445566") {
            userPinColor = pinColor[userPhoneNum!]!
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.navigationController?.viewControllers.firstIndex(of: self) == nil {
            // Back button pressed because self is no longer in the navigation stack.
            // Stop ranging if needed
            beaconManager.stopRangingBeacons(in: region)
        
            if (userPhoneNum != "445566") {
                
                 flashFirst5 = false
                 flashOnceWhenAppear = false
                 flashOnceWhenDisappear = false
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

var flashFirst5 = false
var flashOnceWhenAppear = false
var flashOnceWhenDisappear = false
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
            if (!flashFirst5){
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.flashImageView.backgroundColor = UIColor(displayP3Red: 0.100, green: 0.100, blue: 0.100, alpha: 0.1)
                }
                self.flashImageView.backgroundColor = UIColor(white: 1, alpha: 0.3)
                flashFirst5 = true
            }
            
            
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
                    if (flashOnceWhenAppear && !flashOnceWhenDisappear) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.flashImageView.backgroundColor = UIColor(displayP3Red: 0.100, green: 0.100, blue: 0.100, alpha: 0.1)
                        }
                        self.flashImageView.backgroundColor = UIColor(white: 1, alpha: 0.3)
                        flashOnceWhenAppear = false
                        flashOnceWhenDisappear = true
                    }
                    self.timeTickingLabel.text = "No beacons detected nearby. Your location is currently private."
                    hideAllPins()

                } else {
                    self.currRoom = self.majorToRoom[sortedBeaconArr[0].key]!
                   
                    if (userPhoneNum != "445566") {
                        if (!flashOnceWhenAppear) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.flashImageView.backgroundColor = UIColor(displayP3Red: 0.100, green: 0.100, blue: 0.100, alpha: 0.1)
                            }
                            self.flashImageView.backgroundColor = UIColor(white: 1, alpha: 0.3)
                            flashOnceWhenAppear = true
                        }
                        self.timeTickingLabel.text = "Beacons detected. You are in \(prettifyRoom(room: currRoom))"
                        findPinRoom[currRoom + "-" + userPinColor]?.isHidden = false
                        Database.database().reference().child("/DoctorLocation/\(userPhoneNum!)").updateChildValues(["room" : currRoom])
                    }
                }
            } else {
                self.currRoom = "Private"
                hideAllPins()
                if (flashOnceWhenAppear && !flashOnceWhenDisappear) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.flashImageView.backgroundColor = UIColor(displayP3Red: 0.100, green: 0.100, blue: 0.100, alpha: 0.1)
                    }
                    self.flashImageView.backgroundColor = UIColor(white: 1, alpha: 0.3)
                    flashOnceWhenAppear = false
                    flashOnceWhenDisappear = true
                }
                self.timeTickingLabel.text = "No beacons detected nearby. Your location is currently private."

            }
    }
    
}
}

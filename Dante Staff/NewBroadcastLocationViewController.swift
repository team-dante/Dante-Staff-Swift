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
    
    @IBOutlet weak var outerImageView: UIView!
    @IBOutlet weak var scrollViewContent: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var labelSecondView: UILabel!
    @IBOutlet weak var currentStaffPin: UIView!
    
    var fpc : FloatingPanelController!
    var staffVC : StaffPinViewController!
    
    var beaconManager: KTKBeaconManager!
    var region: KTKBeaconRegion!
    var staffPhoneNumber : String?
    // records a queue of 10 distances for each beacon
    var roomDict: [Int: [Double]] = [1: [], 2: [], 3:[]]
    // map beacon major to the real clinic room
    let majorToRoom = [ 1: "LA1", 2: "TLA", 3: "CT" ]
    // map beacon major to its corresponding cutoff value (1m)
    let cutoff = [1: 1.5, 2: 1.5, 3: 1.5]
    // after 5 rounds, perform stats analysis
    let threshold = 5
    var count = 0
    var currRoom = ""
    var staffColor : [String:String] = [
        "111": "255-220-36",
        "222": "255-0-0",
        "333": "0-255-240",
        "444": "20-255-0",
        "555": "20-122-46",
        "666": "35-145-152",
        "777": "48-93-209",
        "888": "157-48-209",
        "999": "0-19-118",
        "1000": "255-255-255"
    ]
    let ratio_of_414_to_375 = 1.104
    let circlePinWidth414 = 10.0
    let circlePinHeight414 = 10.0
    // when map's height changes, these coordinates MUST be changed
    var freeMapDict : [String: [[String : (Int, Int)]]] = [
        "LA1" : [["156,325" : (156, 325)], ["180,326" : (180, 326)]],
        "TLA" : [["351,255" : (351, 255)], ["381,259" : (381, 259)]],
        "CT" : [["55,324" : (55, 324)], ["11,337" : (11, 337)]],
    ]
    var usedMapDict : [String : [[String : (Int, Int)]]] = [
        "LA1" : [],
        "TLA" : [],
        "CT" : []
    ]
    var previousLocation : [(String, String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // used for zooming outerImageView
        scrollViewContent.delegate = self
        scrollViewContent.minimumZoomScale = 1.0
        scrollViewContent.maximumZoomScale = 3.0
        // important!! this bounces the image back to original size when users zoom out
        scrollViewContent.zoomScale = 1.0
        
        if UIScreen.main.bounds.width == 414 {
            imageView.image = UIImage(named: "clinic-map-414x450")
        } else if UIScreen.main.bounds.width == 375 {
            imageView.image = UIImage(named: "clinic-map-375x450")
        }
        
        self.navigationController!.navigationBar.topItem!.title = "Stop"
        
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
        
        staffPhoneNumber = String((Auth.auth().currentUser?.email?.split(separator: "@")[0] ?? "N/A"))
        
        // update staff pin color
        self.getCurrentStaffPinColor(input: staffPhoneNumber!)
        
        // callback is called when completion(true) or done is true
        // run the code below before executing the beacons
        self.getStaffLocation { (done) in
            if done {
                self.updateStaffLocation()

                Kontakt.setAPIKey("IKLlxikqjxJwiXbyAgokGeLkcZqipAnc")
                
                // Initialize Beacon Manager
                self.beaconManager = KTKBeaconManager(delegate: self)
                self.beaconManager.requestLocationAlwaysAuthorization()
                
                // Create Beacon Region
                self.region = KTKBeaconRegion(proximityUUID: UUID(uuidString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")!, identifier: "region-identifier")
                
                self.beaconManager.startRangingBeacons(in: self.region)
            }
        }
    }
    
    
    // return flashImageView when zooming
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return outerImageView
    }
    
    func getCurrentStaffPinColor(input : String) {
        let color = staffColor[input]
        let rgb = color!.split(separator: "-")
        let r = CGFloat(Int(rgb[0])!)
        let g = CGFloat(Int(rgb[1])!)
        let b = CGFloat(Int(rgb[2])!)
        
        
        let circleLayer = CAShapeLayer()
        circleLayer.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 18.0, height: 18.0)).cgPath
        circleLayer.fillColor = UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1.0).cgColor
        circleLayer.strokeColor = UIColor.white.cgColor
        currentStaffPin.layer.addSublayer(circleLayer)
    }
    
    func addPinToMap(key : String, pinColor : String, roomString: String) {
        let rgb = pinColor.split(separator: "-")
        let r = CGFloat(Int(rgb[0])!)
        let g = CGFloat(Int(rgb[1])!)
        let b = CGFloat(Int(rgb[2])!)
        
        let circleLayer414 = CAShapeLayer()
        let circleLayer375 = CAShapeLayer()
        
        // var freeMapDict : [String: [[String : (Int, Int)]]] = [
        //     "LA1" : [["156,325" : (156, 325)], ["180,326" : (180, 326)]],
        //     "TLA" : [["351,255" : (351, 255)], ["381,259" : (381, 259)]],
        //     "CT" : [["55,324" : (55, 324)], ["11,337" : (11, 337)]],
        // ]
        // ["23,235" : (23, 235)] => access (23, 235) without the key
        let x414 = Double(self.freeMapDict[roomString]![0].values.first!.0)
        let y414 = Double(self.freeMapDict[roomString]![0].values.first!.1)
        
        let x375 = x414/self.ratio_of_414_to_375
        let y375 = y414
        
        if UIScreen.main.bounds.width == 414 {
            circleLayer414.path = UIBezierPath(ovalIn: CGRect(x: x414, y: y414, width: self.circlePinWidth414, height: self.circlePinHeight414)).cgPath
            circleLayer414.fillColor = UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1.0).cgColor
            circleLayer414.strokeColor = UIColor.white.cgColor
        } else if UIScreen.main.bounds.width == 375 {
            circleLayer375.path = UIBezierPath(ovalIn: CGRect(x: x375, y: y375, width: (self.circlePinWidth414/self.ratio_of_414_to_375), height: (self.circlePinHeight414/self.ratio_of_414_to_375))).cgPath
            circleLayer375.fillColor = UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1.0).cgColor
            circleLayer375.strokeColor = UIColor.white.cgColor
        }
        
        let circleLayer414Name = "\(Int(x414)),\(Int(y414))-\(key)-\(roomString)-layer414"
        circleLayer414.name = circleLayer414Name
        let circleLayer375Name = "\(Int(x375)),\(Int(y375))-\(key)-\(roomString)-layer375"
        circleLayer375.name = circleLayer375Name
        
        let tupleOfPrevLocation = (circleLayer414Name, circleLayer375Name)
        
        self.outerImageView.layer.addSublayer(circleLayer414)
        self.outerImageView.layer.addSublayer(circleLayer375)
        
        // move used pin from freeMapDict to usedMapDict
        let firstElement = self.freeMapDict[roomString]?.remove(at: 0)
        self.usedMapDict[roomString]?.append(firstElement!)
        
//        print("tupleOfPrevLocation====>", tupleOfPrevLocation)
        self.previousLocation.append(tupleOfPrevLocation)
    }
    
    func getStaffLocation(completion: @escaping (Bool) -> Void) {
        Database.database().reference().child("StaffLocation").observeSingleEvent(of: .value) { (DataSnapshot) in
            let dict = DataSnapshot.value as! [String : AnyObject]
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                self.outerImageView.backgroundColor = UIColor(displayP3Red: 0.100, green: 0.100, blue: 0.100, alpha: 0.1)
            })
            self.outerImageView.backgroundColor = UIColor(white: 1, alpha: 0.3)
            
            for (key, value) in dict {
                let pinColor : String = (value["pinColor"] as! String)
                let roomString : String = (value["room"] as! String)
                
                if roomString != "Private" {
                    self.addPinToMap(key: key, pinColor: pinColor, roomString: roomString)
                }
            }
            completion(true)
        }
    }
    
    func removePinFromMap(layerName : String, staffPhoneNum : String, stafflayer : CALayer) {
        let arr$0 = layerName.components(separatedBy: "-")
        let coords = arr$0[0]
        let phoneNum = arr$0[1]
        let roomString = arr$0[2]
        let layerType = arr$0[3]
        if (phoneNum == staffPhoneNum) {
            // remove sublayer that contains staffPhoneNum
            stafflayer.removeFromSuperlayer()
            // update usedMapDict and freeMapDict once
            if layerType != "layer375" {
                var count = 0
                var removedIndex : Int!
                for eachDict in self.usedMapDict[roomString]! {
                    // if eachDict with specific coords exist
                    // print("eachDict=====>", eachDict)
                    // print("coords=====>", coords)
                    if eachDict[coords] != nil {
                        removedIndex = count
                    }
                    count += 1
                }
                // print("roomString=====>", roomString)
                // print("removedIndex=======>", removedIndex)
                let removedElement = self.usedMapDict[roomString]?.remove(at: removedIndex!)
                self.freeMapDict[roomString]?.append(removedElement!)
            }
        }
    }
    
    func updateStaffLocation() {
        // Listen for changes to the items in a list. This event is triggered any time a child node is modified.
        // The snapshot passed to the event listener contains the updated data for the child.
        Database.database().reference().child("StaffLocation").observe(.childChanged) { (DataSnapshot) in
            let updatedChildDict = DataSnapshot.value as! [String : AnyObject]
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                self.outerImageView.backgroundColor = UIColor(displayP3Red: 0.100, green: 0.100, blue: 0.100, alpha: 0.1)
            })
            self.outerImageView.backgroundColor = UIColor(white: 1, alpha: 0.3)
            
            let staffPhoneNum = DataSnapshot.key
            let pinColor = updatedChildDict["pinColor"] as! String
            let roomString = updatedChildDict["room"] as! String
            
            if roomString == "Private" {
                print("IF.Key-updatedChildDict===>\(DataSnapshot.key)-\(updatedChildDict)")
                self.outerImageView.layer.sublayers?.forEach {
                    if $0.name != nil {
//                        print("$0======>", $0.name)
                        let layerName = $0.name
                        self.removePinFromMap(layerName : layerName!, staffPhoneNum: staffPhoneNum, stafflayer: $0)
                    }
                }
            } else if updatedChildDict["room"] as! String != "Private" {
//                print("Else.Key-updatedChildDict===>\(DataSnapshot.key)-\(updatedChildDict)")
                // remove old locations for both iphones 414 and 375
                var foundOldLocation414 : String = ""
                var foundOldLocation375 : String = ""
//                print("previousLocation=====>", self.previousLocation)
                for eachTuple in self.previousLocation {
                    let arrStr = eachTuple.0.components(separatedBy: "-")
//                    print("arrStr[1]====>", arrStr[1])
//                    print("arrStr[2]====>", arrStr[2])
                    if arrStr[1] == staffPhoneNum {
                        foundOldLocation414 = eachTuple.0
                        foundOldLocation375 = eachTuple.1
                    }
                }
//                print("foundOldLocation414===>", foundOldLocation414)
//                print("foundOldLocation375===>", foundOldLocation375)
                self.outerImageView.layer.sublayers!.forEach {
                    if $0.name == foundOldLocation414 || $0.name == foundOldLocation375 {
                        self.removePinFromMap(layerName: $0.name!, staffPhoneNum: DataSnapshot.key, stafflayer: $0)
                    }
                }
                // add new pin after removing old pins from 2 iphones 414 and 375
                self.addPinToMap(key: staffPhoneNum, pinColor: pinColor, roomString: roomString)
            }
            
            print("freeMapDict===>", self.freeMapDict)
            print("usedMapDict===>", self.usedMapDict)
        }
    }
    
    // if FloatingPanel's position is at tip, then it will be at half
    @objc func handleSurface(tapGesture: UITapGestureRecognizer) {
        
        // Modify legendTopConstraint to 20 after viewDidLoad() is called
        // put this in sending controller
        if UIScreen.main.bounds.height == 667.0 {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateLegendTopConstraintTo20"), object: nil)
        }
        
        if fpc.position == .tip {
            fpc.move(to: .full, animated: true)
        } else if fpc.position == .full {
            // Modify legendTopConstraint to 0 after viewDidLoad() is called
            // put this in sending controller
            if UIScreen.main.bounds.height == 667.0 {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "updateLegendTopConstraintTo0"), object: nil)
            }
            fpc.move(to: .tip, animated: true)
        } else if fpc.position == .half {
            fpc.move(to: .full, animated: true)
        }
    }
    
    func floatingPanelWillBeginDragging(_ vc: FloatingPanelController) {
        
        // Modify legendTopConstraint to 20 after viewDidLoad() is called
        // put this in sending controller
        if UIScreen.main.bounds.height == 667.0 {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateLegendTopConstraintTo20"), object: nil)
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
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        if self.navigationController?.viewControllers.firstIndex(of: self) == nil {
            // Back button pressed because self is no longer in the navigation stack.
            // Stop ranging if needed
            beaconManager.stopRangingBeacons(in: region)
        }
        
        self.navigationController!.navigationBar.topItem!.title = "Back"
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
                return 200.0
            } else if height == 812.0 { // iPhone 11 Pro
                return 120.0
            } else if height == 736.0 { // iPhone 8 Plus
                return 100.0
            } else if height == 667.0 { // iPhone 8
                return 40.0
            }
        default: return nil // Or case .hidden: return nil
        }
        return nil
    }
}

extension NewBroadcastLocationViewController : KTKBeaconManagerDelegate {
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
                    Database.database().reference().child("/StaffLocation/\(staffPhoneNumber!)/room").setValue("Private")
                    self.labelSecondView.text = "No beacons detected nearby. Your location is private."
                    
                } else {
                    self.currRoom = self.majorToRoom[sortedBeaconArr[0].key]!
                    
                    var beautifiedCurrRoom = currRoom
                    switch beautifiedCurrRoom {
                        case "LA1":
                            beautifiedCurrRoom = "Linear Accelerator 1"
                        case "TLA":
                            beautifiedCurrRoom = "Trilogy Linear Accelerator"
                        case "CT":
                            beautifiedCurrRoom = "CT Simulator"
                        default:
                            beautifiedCurrRoom = "N/A"
                    }
                    self.labelSecondView.text = "Beacons detected. You are in \(beautifiedCurrRoom)."
                    Database.database().reference().child("/StaffLocation/\(staffPhoneNumber!)").updateChildValues(["room" : currRoom])
                }
            } else {
                self.currRoom = "Private"
                Database.database().reference().child("/StaffLocation/\(staffPhoneNumber!)/room").setValue("Private")
                self.labelSecondView.text = "No beacons detected nearby. Your location is private."
            }
        }
        
    }
}

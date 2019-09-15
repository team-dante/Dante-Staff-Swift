//
//  StaffPinViewController.swift
//  Dante Staff
//
//  Created by Hung Phan on 9/12/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit
import Firebase

class StaffLegend {
    var staffPhoneNum : String!
    var staffName : String!
    var staffColor : String!
    var staffLocation: String!
    
    init(spn: String, sn: String, sc: String, sl: String) {
        staffPhoneNum = spn
        staffName = sn
        staffColor = sc
        staffLocation = sl
    }
}

class StaffPinViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var legendTopConstraint: NSLayoutConstraint!
    
    var staffList : [StaffLegend] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // put this in receiving controller viewDidLoad()
        // Modify legendTopConstraint to 0 after viewDidLoad() is called
        NotificationCenter.default.addObserver(self, selector: #selector(updateLegendTopConstraintTo0(_:)), name: Notification.Name(rawValue: "updateLegendTopConstraintTo0"), object: nil)
        
        // Modify legendTopConstraint to 20 after viewDidLoad() is called
        NotificationCenter.default.addObserver(self, selector: #selector(updateLegendTopConstraintTo20(_:)), name: Notification.Name(rawValue: "updateLegendTopConstraintTo20"), object: nil)
        
        if UIScreen.main.bounds.height == 667.0 {
            legendTopConstraint.constant = 0
        }

        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: titleView.frame.height - 3
            , width: titleView.frame.width, height: 3.0)
        bottomBorder.backgroundColor = UIColor.white.cgColor
        titleView.layer.addSublayer(bottomBorder)
        
        tableView.separatorColor = UIColor.white

        tableView.delegate = self
        tableView.dataSource = self
        
        staffList = [
            StaffLegend(spn: "111", sn: "Dr. Roa", sc: "255-220-36", sl: "Private"),
            StaffLegend(spn: "222", sn: "Dr. Kuo", sc: "255-0-0", sl: "Private"),
            StaffLegend(spn: "333", sn: "Dr. Gan", sc: "0-255-240", sl: "Private"),
            StaffLegend(spn: "444", sn: "Ms. Shen", sc: "20-255-0", sl: "Private"),
            StaffLegend(spn: "555", sn: "Ms. Moore", sc: "20-122-46", sl: "Private"),
            StaffLegend(spn: "666", sn: "Mrs. Zeleznik", sc: "35-145-152", sl: "Private"),
            StaffLegend(spn: "777", sn: "Mr. JRoa", sc: "48-93-209", sl: "Private"),
            StaffLegend(spn: "888", sn: "Mr. Phan", sc: "157-48-209", sl: "Private"),
            StaffLegend(spn: "999", sn: "Mr. Liang", sc: "0-19-118", sl: "Private"),
            StaffLegend(spn: "1000", sn: "Staff 10", sc: "255-255-255", sl: "Private")
        ]
        
        self.getStaffLocation { (done) in
            if done {
                self.updateStaffLocation()
            }
        }
    }
    
    @objc func updateLegendTopConstraintTo0(_ notification: Notification) {
        self.legendTopConstraint.constant = 0
    }
    
    @objc func updateLegendTopConstraintTo20(_ notification: Notification) {
        self.legendTopConstraint.constant = 20
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return staffList.count
    }
    
    func getStaffLocation(completion: @escaping (Bool) -> Void) {
        Database.database().reference().child("StaffLocation").observeSingleEvent(of: .value) { (DataSnapshot) in
            let allStaffDict = DataSnapshot.value as! [String : AnyObject]
            
            for (key, value) in allStaffDict {
                for eachObject in self.staffList {
                    if eachObject.staffPhoneNum == key {
                        eachObject.staffLocation = value["room"] as? String
                    }
                }
            }
            
            self.tableView.reloadData()
            completion(true)
        }
    }
    
    func updateStaffLocation() {
        Database.database().reference().child("StaffLocation").observe(.childChanged) { (DataSnapshot) in
            let staffKey = DataSnapshot.key
            let staffUpdatedDict = DataSnapshot.value as! [String : AnyObject]
            
            for eachObject in self.staffList {
                if eachObject.staffPhoneNum == staffKey {
                    eachObject.staffLocation = staffUpdatedDict["room"] as? String
                }
            }
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StaffPinCell", for: indexPath) as? StaffPinTableViewCell else {
            fatalError("==>The dequeued cell is not an instance of StaffPinViewController.")
        }
            
        let staff = self.staffList[indexPath.row]
        cell.staffName.text = staff.staffName
        cell.staffName.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        if staff.staffLocation == "Private" {
            cell.staffLocation.text = "Location: Private"
        }
        else {
            cell.staffLocation.text = "Location: \(self.prettifyRoom(room: staff.staffLocation))"   
        }
        
        cell.staffLocation.font = UIFont.italicSystemFont(ofSize: 17)
        let color = staff.staffColor
        let rgb = color!.split(separator: "-")
        let r = CGFloat(Int(rgb[0])!)
        let g = CGFloat(Int(rgb[1])!)
        let b = CGFloat(Int(rgb[2])!)
        let circleLayer = CAShapeLayer()
        circleLayer.path = UIBezierPath(ovalIn: CGRect(x: 20.0, y: 35.0, width: 18.0, height: 18.0)).cgPath
        circleLayer.fillColor = UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1.0).cgColor
        circleLayer.strokeColor = UIColor.white.cgColor
        cell.layer.addSublayer(circleLayer)
        cell.selectionStyle = .none
        
        return cell
    }
}



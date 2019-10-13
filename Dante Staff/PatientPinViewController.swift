//
//  PatientPinViewController.swift
//  Dante Staff
//
//  Created by Xinhao Liang on 9/9/19.
//  Updated by Hung Phan on 9/12/19
//  Copyright © 2019 Hung Phan. All rights reserved.
//

//
//  PinRefViewController.swift
//  Dante Patient
//
//  Created by Xinhao Liang on 7/12/19.
//  Updated by Hung Phan on 9/12/19
//  Copyright © 2019 Xinhao Liang. All rights reserved.
//

import UIKit
import Firebase

class PatientPinViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var ref: DatabaseReference!
    
    var patients = [[String: String]]()
    var allSubLayers : [CALayer] = []
    
    // For iOS 10 only
    private lazy var shadowLayer: CAShapeLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        
        ref = Database.database().reference()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: titleView.frame.height - 3, width: titleView.frame.width, height: 3.0)
        bottomBorder.backgroundColor = UIColor.white.cgColor
        titleView.layer.addSublayer(bottomBorder)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // call observe to always listen for patient location changes
        ref.child("PatientLocation").observe(.value, with: {(snapshot) in
            
            // clear patients list data at refreshing
            self.patients = []
            if let patients = snapshot.value as? [String: Any] {
                for patient in patients {
                    if let pat = patient.value as? [String: String] {
                        let room = pat["room"]! // e.g. "CTRoom"
                        if room != "Private" {
                            let name = pat["name"]!
                            let color = pat["pinColor"]!
                            var startTime = pat["startTime"]!
                            
                            if startTime != "N/A" {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "hh:mm a"
                                startTime = dateFormatter.string(from: NSDate(timeIntervalSince1970: Double(startTime)!) as Date)
                            }
                            
                            let formattedRoomStr = self.prettifyRoom(room: room)
                            let patientDict = ["pinColor": color, "room": formattedRoomStr, "patientName": name, "startTime" : startTime]
                            
                            self.patients.append(patientDict)
                        }
                    }
                }
                // reload the tableView immediately
                self.tableView.reloadData()
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.patients.count == 0 {
            return 1
        } else {
            return self.patients.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PatientPinTableViewCell", for: indexPath) as? PatientPinTableViewCell else {
            fatalError("==>The dequeued cell is not an instance of PatientPinViewController.")
        }

        if self.patients.count == 0 {
            cell.layer.sublayers!.forEach {
                if $0.name == "circleLayer" {
                    $0.removeFromSuperlayer()
                }
            }
            cell.emptyMiddleLabel.isHidden = false
//            self.tableView.separatorStyle = .none
            cell.emptyMiddleLabel.text = "There are no patients in the clinic at the meantime."
            cell.patientLabel.isHidden = true
            cell.roomLabel.isHidden = true
            cell.checkedInTime.isHidden = true
            cell.selectionStyle = .none
        } else {
//            self.tableView.separatorStyle = .singleLine
            cell.emptyMiddleLabel.isHidden = true
            cell.patientLabel.isHidden = false
            cell.roomLabel.isHidden = false
            cell.checkedInTime.isHidden = false
            let patient = self.patients[indexPath.row]
            
            // parse color
            let color = patient["pinColor"]!
            let rgb = color.split(separator: "-")
            let r = CGFloat(Int(rgb[0])!)
            let g = CGFloat(Int(rgb[1])!)
            let b = CGFloat(Int(rgb[2])!)
            
            let circleLayer = CAShapeLayer()
            circleLayer.path = UIBezierPath(ovalIn: CGRect(x: 20.0, y: 38.0, width: 18.0, height: 18.0)).cgPath
            circleLayer.fillColor = UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1.0).cgColor
            circleLayer.strokeColor = UIColor.white.cgColor
            
            circleLayer.name = "circleLayer"
            cell.layer.addSublayer(circleLayer)
            self.allSubLayers.append(circleLayer)
            
            cell.patientLabel.text = patient["patientName"]
            cell.roomLabel.text = "Currently in " + patient["room"]!
            cell.checkedInTime.text = "Checked in at \(patient["startTime"]!)"
            cell.selectionStyle = .none
            cell.setNeedsDisplay()
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

}

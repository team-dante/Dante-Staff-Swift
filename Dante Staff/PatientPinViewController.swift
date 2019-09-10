//
//  PatientPinViewController.swift
//  Dante Staff
//
//  Created by Xinhao Liang on 9/9/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

//
//  PinRefViewController.swift
//  Dante Patient
//
//  Created by Xinhao Liang on 7/12/19.
//  Copyright © 2019 Xinhao Liang. All rights reserved.
//

import UIKit
import Firebase

class PatientPinViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var ref: DatabaseReference!
    
    var patients = [[String: String]]()
    
    // For iOS 10 only
    private lazy var shadowLayer: CAShapeLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.rowHeight = 80
        
        ref = Database.database().reference()
        
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: titleView.frame.height - 3, width: titleView.frame.width, height: 3.0)
        bottomBorder.backgroundColor = UIColor.lightGray.cgColor
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
                            
                            let formattedRoomStr = self.prettifyRoom(room: room)
                            let patientDict = ["pinColor": color, "room": formattedRoomStr, "patientName": name]
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
        return self.patients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PatientPinTableViewCell", for: indexPath) as? PatientPinTableViewCell {
            
            let patient = self.patients[indexPath.row]
            
            // parse color
            let color = patient["pinColor"]!
            let rgb = color.split(separator: "-")
            let r = CGFloat(Int(rgb[0])!)
            let g = CGFloat(Int(rgb[1])!)
            let b = CGFloat(Int(rgb[2])!)
            
            let circleLayer = CAShapeLayer()
            circleLayer.path = UIBezierPath(ovalIn: CGRect(x: 20.0, y: 18.0, width: 18.0, height: 18.0)).cgPath
            circleLayer.fillColor = UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1.0).cgColor
            circleLayer.strokeColor = UIColor.black.cgColor
            
            let rectLayer = CAShapeLayer()
            rectLayer.path = UIBezierPath(rect: CGRect(x: 28.0, y: 36.0, width: 2.0, height: 20.0)).cgPath
            rectLayer.fillColor = UIColor.black.cgColor
            
            cell.layer.addSublayer(circleLayer)
            cell.layer.addSublayer(rectLayer)
            
            cell.patientLabel.text = patient["patientName"]
            cell.roomLabel.text = patient["room"]
            
            cell.setNeedsDisplay()
            
            return cell
        }
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections = 0
        if self.patients.count != 0 {
            tableView.separatorStyle = .singleLine
            numOfSections = 1
            tableView.backgroundView = nil
        } else {
            let defaultLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            defaultLabel.text = "There are no patients in the clinic at the meantime"
            defaultLabel.textColor = UIColor.lightGray
            defaultLabel.textAlignment = .center
            defaultLabel.numberOfLines = 0
            tableView.backgroundView = defaultLabel
            tableView.separatorStyle = .none
        }
        return numOfSections
    }

}

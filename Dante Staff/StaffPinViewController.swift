//
//  StaffPinViewController.swift
//  Dante Staff
//
//  Created by Hung Phan on 9/12/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit

class StaffLegend {
    var staffName : String!
    var staffColor : String!
    
    init(sn: String, sc: String) {
        staffName = sn
        staffColor = sc
    }
}

class StaffPinViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return staffList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "StaffPinCell", for: indexPath) as? StaffPinTableViewCell {
            
            let staff = self.staffList[indexPath.row]
            cell.staffName.text = staff.staffName
            let color = staff.staffColor
            let rgb = color!.split(separator: "-")
            let r = CGFloat(Int(rgb[0])!)
            let g = CGFloat(Int(rgb[1])!)
            let b = CGFloat(Int(rgb[2])!)
            let circleLayer = CAShapeLayer()
            circleLayer.path = UIBezierPath(ovalIn: CGRect(x: 20.0, y: 30.0, width: 18.0, height: 18.0)).cgPath
            circleLayer.fillColor = UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1.0).cgColor
            circleLayer.strokeColor = UIColor.white.cgColor
            cell.layer.addSublayer(circleLayer)
            return cell
        }
        return UITableViewCell()
    }


    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var tableView: UITableView!

    var staffList : [StaffLegend] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: titleView.frame.height - 3
            , width: titleView.frame.width, height: 3.0)
        bottomBorder.backgroundColor = UIColor.white.cgColor
        titleView.layer.addSublayer(bottomBorder)
        
        tableView.separatorColor = UIColor.white

        tableView.delegate = self
        tableView.dataSource = self
        
        staffList = [
            StaffLegend(sn: "Dr. Roa", sc: "255-220-36"),
            StaffLegend(sn: "Dr. Kuo", sc: "255-0-0"),
            StaffLegend(sn: "Dr. Gan", sc: "0-255-240"),
            StaffLegend(sn: "Ms. Shen", sc: "20-255-0"),
            StaffLegend(sn: "Ms. Moore", sc: "20-122-46"),
            StaffLegend(sn: "Mrs. Zeleznik", sc: "35-145-152"),
            StaffLegend(sn: "Mr. JRoa", sc: "48-93-209"),
            StaffLegend(sn: "Mr. Phan", sc: "157-48-209"),
            StaffLegend(sn: "Mr. Liang", sc: "0-19-118"),
            StaffLegend(sn: "Staff 10", sc: "255-255-255")
        ]
    }
}

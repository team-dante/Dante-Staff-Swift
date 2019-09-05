//
//  DatesViewController.swift
//  Dante Staff
//
//  Created by Hung Phan on 8/31/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit
import Firebase

class DateCustom {
    var rawDate : String!
    var date : String!
    var daysAgo : String!
    var daysAgoSortedInt : Int!
    
    init(rd: String, d : String, dA: String) {
        rawDate = rd
        date = d
        if (dA == "0" || dA == "1") {
            daysAgo = dA + " day ago"
        } else {
            daysAgo = dA + " days ago"
        }
        daysAgoSortedInt = Int(dA)
    }
}

class DateViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var receivedData : String = ""
    var passedData : String = ""
    var dates : [DateCustom] = []
    var toggle = true
    var rightBarButton : UIButton!

    @IBOutlet weak var tableBackground: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refresh: UIImageView!
    @IBOutlet weak var filterPopupView: UIView!
    @IBOutlet weak var viewWeeklyBtn: UIButton!
    @IBOutlet weak var viewMonthlyBtn: UIButton!
    @IBOutlet weak var viewYearlyBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewWeeklyBtn.layer.cornerRadius = 10.0
        self.viewMonthlyBtn.layer.cornerRadius = 10.0
        self.viewYearlyBtn.layer.cornerRadius = 10.0
        self.filterPopupView.layer.cornerRadius = 10.0
        
        rightBarButton = UIButton(type: .custom)
        let image = UIImage(named: "filter.png")
        rightBarButton.setImage(image, for: .normal)
        // use background color for debugging
//        rightBarButton.backgroundColor = UIColor.red
        rightBarButton.imageView?.contentMode = .scaleAspectFit
        // add padding top and bottom to image and text
        rightBarButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 0)
        // To remove left and right inset, set width constraint for the button. Do not use UIEdgeInsets to remove inset
        rightBarButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)
        self.navigationItem.rightBarButtonItem?.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(popupView(_:))))
        
        self.tableBackground.layer.cornerRadius = 10.0
        self.tableView.layer.cornerRadius = 10.0
        
        refresh.isUserInteractionEnabled = true
        refresh.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(refreshTapped)))
    }
    
    @objc func popupView(_ recognizer: UITapGestureRecognizer) {
        if (toggle == true) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(popupView(_:)))
            self.filterPopupView.isHidden = false
            toggle = false
        } else if (toggle == false) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)
            self.navigationItem.rightBarButtonItem?.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(popupView(_:))))
            self.filterPopupView.isHidden = true
            toggle = true
        }
    }
    
    @objc func refreshTapped(_ recognizer: UITapGestureRecognizer) {
        dates = []
        loadDates()
        UIView.animate(withDuration: 1) {
            self.refresh.transform = self.refresh.transform.rotated(by: CGFloat.pi/1)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // deselect selected row
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
        
        self.filterPopupView.isHidden = true
        
        print("==>receivedDataFromPatientVC=", receivedData)
        
        // load data to table
        self.tableView.delegate = self
        self.tableView.dataSource = self
        dates = []
        loadDates()
    }
    
    func loadDates() {
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        
        ref.child("Patients").queryOrdered(byChild: "patientPhoneNumber").queryEqual(toValue: receivedData).observeSingleEvent(of: .value) { (DataSnapshot) in
            var firstName = ""
            var lastName = ""
            if DataSnapshot.exists() {
                let dict = DataSnapshot.value as! [String : AnyObject]
                for (_, value) in dict {
                    firstName = value["firstName"] as! String
                    lastName = value["lastName"] as! String
                }
            } else {
                print("==>DataSnapshot does not exist")
            }
            self.title = "\(firstName) \(Array(lastName)[0])."
        }
        
        ref.child("PatientVisitsByDates/\(receivedData)").observeSingleEvent(of: .value) { (DataSnapshot) in
            if DataSnapshot.exists() {
                let dict = DataSnapshot.value as! [String : AnyObject]
                for (key, _) in dict {
                    let prettifiedDate = self.prettifyDate(date: key)
                    let daysAgo = self.daysAgoFunc(start: key)
                    self.dates.append(DateCustom(rd: key,d: prettifiedDate, dA: daysAgo))
                    self.dates = self.dates.sorted {
                        $0.daysAgoSortedInt < $1.daysAgoSortedInt
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            } else {
                print("==>DataSnapshot does not exist")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "DateTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DateTableViewCell else {
            fatalError("==>The dequeued cell is not an instance of DateTableViewCell.")
        }
        
        let date = dates[indexPath.row]
        cell.date.text = date.date
        cell.daysLeft.text = date.daysAgo
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let date = dates[indexPath.row]
        self.passedData = self.receivedData + "@" + date.rawDate
        self.performSegue(withIdentifier: "next", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! DetailViewController
        vc.receivedData = self.passedData
    }

}

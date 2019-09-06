//
//  DatesViewController.swift
//  Dante Staff
//
//  Created by Hung Phan on 8/31/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit
import Firebase

class Monthly {
    var monthName : String!
    var totalTimeSpent : Double!
    var timeSpentPerVisit : Double!
    var numberOfDaysVisited : Int!
    
    init(mn: String, time: Double, tspv: Double, nodv: Int) {
        monthName = mn
        totalTimeSpent = time
        timeSpentPerVisit = tspv
        numberOfDaysVisited = nodv
    }
}

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
    var passedDataWeekly : String!
    var passedDataMonthly: String!
    var passedDataYearly: String!
    var months : [Monthly] = []
    var monthDict = Dictionary<String, Set<String>>()
    var tableTypes : String!
    var dates : [DateCustom] = []
    var toggle = true
    var rightBarButton : UIButton!

    @IBOutlet weak var tableBackground: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refresh: UIImageView!
    @IBOutlet weak var filterPopupView: UIView!
    @IBOutlet weak var viewDailyBtn: UIButton!
    @IBOutlet weak var viewWeeklyBtn: UIButton!
    @IBOutlet weak var viewMonthlyBtn: UIButton!
    @IBOutlet weak var viewYearlyBtn: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBAction func viewWeeklyPressed(_ sender: Any) {
        self.passedDataWeekly = receivedData
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)
        self.navigationItem.rightBarButtonItem?.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(popupView(_:))))
        self.filterPopupView.isHidden = true
        self.toggle = true

    }
    
    @IBAction func viewDailyPressed(_ sender: Any) {
        self.passedDataMonthly = receivedData
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)
        self.navigationItem.rightBarButtonItem?.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(popupView(_:))))
        self.filterPopupView.isHidden = true
        self.toggle = true
        
        self.tableTypes = ""
        self.headerLabel.text = "Patient Visit By Date"
        dates = []
        loadDates()
    }
    
    @IBAction func viewMonthlyPressed(_ sender: Any) {
        self.passedDataMonthly = receivedData
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)
        self.navigationItem.rightBarButtonItem?.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(popupView(_:))))
        self.filterPopupView.isHidden = true
        self.toggle = true
        
        self.tableTypes = "monthly"
        self.headerLabel.text = "Patient Visit By Month"
        months = []
        self.loadMonths()
    }
    
    @IBAction func viewYearlyPressed(_ sender: Any) {
        self.passedDataYearly = receivedData
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)
        self.navigationItem.rightBarButtonItem?.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(popupView(_:))))
        self.filterPopupView.isHidden = true
        self.toggle = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewDailyBtn.layer.cornerRadius = 10.0
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
        if (tableTypes == "monthly") {
            months = []
            loadMonths()
        } else {
            dates = []
            loadDates()
        }
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
    
    func loadMonths() {
        var ref : DatabaseReference!
        
        ref = Database.database().reference()
        
        ref.child("PatientVisitsByDates/\(receivedData)").observeSingleEvent(of: .value) { (DataSnapshot) in
            if DataSnapshot.exists() {
                let dict = DataSnapshot.value as! [String : AnyObject]
                let sortedDict = dict.sorted {
                    $0.0 < $1.0
                }
                // print(sortedDict)
                
                // extract [month : [set of dates in that month]
                // 2019-08 - ["2019-08-26", "2019-08-21", "2019-08-22", "2019-08-06"]
                // 2019-09 - ["2019-09-02", "2019-09-03"]
                // 2019-07 - ["2019-07-29"]
                var tempKey = ""
                var monthSet = Set<String>()
                for (key, _) in sortedDict {
                    print("key=>\(key)")
                    if (tempKey == "" ) {
                        tempKey = String(key.prefix(7))
                        monthSet.insert(key)
                    }
                    else if (key.prefix(7) != tempKey) {
                        self.monthDict[tempKey] = monthSet
                        tempKey = String(key.prefix(7))
                        monthSet = Set<String>()
                        monthSet.insert(key)
                        
                    } else if key.prefix(7) == tempKey {
                        monthSet.insert(key)
                    }
                }
                self.monthDict[tempKey] = monthSet
                monthSet = Set<String>()
                
            } else {
                print("==>DataSnapshot does not exist")
            }
            
            for (key, _) in self.monthDict {
                self.months.append(Monthly(mn: key, time: 0.0, tspv: 0.0, nodv: 0))
            }
            
            for (key, value) in self.monthDict {
                print("\(key) - \(value)")
                self.getTotalMinutesPerMonth(input: value)
            }
            
        }
    }
    
    func getTotalMinutesPerMonth(input: Set<String>) {
        
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        for eachDate in input {
            ref.child("PatientVisitsByDates/\(receivedData)/\(eachDate)").observeSingleEvent(of: .value) { (DataSnapshot) in
                if DataSnapshot.exists() {
                    let dict = DataSnapshot.value as! [String : AnyObject]
                    // add up total hours for each month
                    var totalTime = 0.0
                    for (_, val) in dict {
                        if (val["inSession"] as! Bool == false) {
                            let minute = ((val["endTime"] as! Double - (val["startTime"] as! Double)) / 60.0)
                            for eachObject in self.months {
                                if eachObject.monthName == eachDate.prefix(7) {
                                    eachObject.totalTimeSpent += minute
                                    totalTime += minute
                                }
                            }
                        } else {
                            let now = NSDate().timeIntervalSince1970
                            let minute = ((Double(now) - (val["startTime"] as! Double)) / 60)
                            for eachObject in self.months {
                                if eachObject.monthName == eachDate.prefix(7) {
                                    eachObject.totalTimeSpent += minute
                                    totalTime += minute
                                }
                            }
                        }
                    }
                    
                    // get average of minutes per visit in one month (total minutes visited / number of days)
                    for eachObject in self.months {
                        if eachObject.monthName == eachDate.prefix(7) {
                            let visitPerMonth = self.monthDict[String(eachDate.prefix(7))]
                            eachObject.timeSpentPerVisit = (eachObject.totalTimeSpent / Double(visitPerMonth!.count))
                            eachObject.numberOfDaysVisited = visitPerMonth!.count
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    print("==>DataSnapshot does not exist")
                }
            }
        }
        

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
        if (tableTypes == "monthly") {
            return months.count
        }
            
        return dates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "DateTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DateTableViewCell else {
            fatalError("==>The dequeued cell is not an instance of DateTableViewCell.")
        }
        
        if (tableTypes == "monthly") {
            let month = months[indexPath.row]
            cell.date.text = self.prettifyMonth(input: month.monthName)
            if (month.numberOfDaysVisited == 0 || month.numberOfDaysVisited == 1) {
                cell.daysLeft.text = "Spent \(month.numberOfDaysVisited!) day in total"
            } else {
                cell.daysLeft.text = "Spent \(month.numberOfDaysVisited!) days in total"
            }
            
            
            return cell
        }
        
        let date = dates[indexPath.row]
        cell.date.text = date.date
        cell.daysLeft.text = date.daysAgo
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableTypes == "monthly") {
            let month = months[indexPath.row]
            print(month)
        } else {
            let date = dates[indexPath.row]
            self.passedData = self.receivedData + "@" + date.rawDate
            self.performSegue(withIdentifier: "next", sender: self)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "next" {
            if let vc = segue.destination as? DetailViewController {
                vc.receivedData = self.passedData
            }
        }

        
    }

}

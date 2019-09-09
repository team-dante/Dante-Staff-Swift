//
//  DatesViewController.swift
//  Dante Staff
//
//  Created by Hung Phan on 8/31/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit
import Firebase

class Yearly {
    var yearName : String!
    var numberOfDaysVisited : Int!
    var allVisits : Set<String>
    
    init(yn: String, nodv: Int, av: Set<String>) {
        yearName = yn
        numberOfDaysVisited = nodv
        allVisits = av
    }
}

class Weekly {
    var weekName : String!
    var numberOfDaysVisited : Int!
    var allVisits : Set<String>
    
    init(wn: String, nodv: Int, av: Set<String>) {
        weekName = wn
        numberOfDaysVisited = nodv
        allVisits = av
    }
}

class Monthly {
    // get "August 2019, September 2019, July 2019"
    var monthName : String!
    // get total minutes in each month
    var totalTimeSpent : Double!
    // get average minute spent per visit in each month. (total minutes / number of days) in one month
    var timeSpentPerVisit : Double!
    // "Spent 4 days in total" -> get the total number of visit per day in one month
    var numberOfDaysVisited : Int!
    // a set of ["2019-08-21", "2019-08-22", "2019-08-26", "2019-08-06"]
    var allVisits : Set<String>
    
    init(mn: String, time: Double, tspv: Double, nodv: Int, av: Set<String>) {
        monthName = mn
        totalTimeSpent = time
        timeSpentPerVisit = tspv
        numberOfDaysVisited = nodv
        allVisits = av
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
    var weeks : [Weekly] = []
    var months : [Monthly] = []
    var years : [Yearly] = []
    var weekDict = Dictionary<String, Set<String>>()
    var monthDict = Dictionary<String, Set<String>>()
    var yearDict = Dictionary<String, Set<String>>()
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)
        self.navigationItem.rightBarButtonItem?.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(popupView(_:))))
        self.filterPopupView.isHidden = true
        self.toggle = true
        
        self.tableTypes = "weekly"
        self.headerLabel.text = "Patient Visit By Week"
        weeks = []
        loadWeeks()

    }
    
    @IBAction func viewDailyPressed(_ sender: Any) {
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)
        self.navigationItem.rightBarButtonItem?.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(popupView(_:))))
        self.filterPopupView.isHidden = true
        self.toggle = true
        
        self.tableTypes = "yearly"
        self.headerLabel.text = "Patient Visit By Year"
        years = []
        self.loadYears()
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
        }
        else if tableTypes == "yearly" {
            years = []
            loadYears()
        }
        else if tableTypes == "weekly" {
            weeks = []
            loadWeeks()
        }
        else {
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
    
    func loadWeeks() {
        var ref : DatabaseReference!
        
        ref = Database.database().reference()
        ref.child("PatientVisitsByDates/\(receivedData)").observeSingleEvent(of: .value) { (DataSnapshot) in
            if DataSnapshot.exists() {
                let dict = DataSnapshot.value as! [String : AnyObject]
                let sortedDict = dict.sorted {
                    $0.0 < $1.0
                }
                
                // extract [week range: [set of dates in that week range]
                // September 2 - 8 : ["2019-07-27", "2019-07-29", "2019-09-03", "2019-08-20"]
                // find the week range based on the date provided
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
//                var strDate = "2019-07-27"
//                var newDate = dateFormatter.date(from: strDate)
//                let startWeek = newDate!.startOfWeek
//                let endWeek = newDate!.endOfWeek
//                dateFormatter.string(from: startWeek!)
//                dateFormatter.string(from: endWeek!)
                var tempKey = ""
                var weekSet = Set<String>()
                var singleWeekRange = ""
                for (key, _) in sortedDict {
                    // get week range based on key (aka date)
                    let startDate : Date = dateFormatter.date(from: String(key))!
                    let endDate : Date = dateFormatter.date(from: String(key))!
                    let startWeek = startDate.startOfWeek
                    let endWeek = endDate.endOfWeek
                    let startWeekStr = dateFormatter.string(from: startWeek!)
                    let endWeekStr = dateFormatter.string(from: endWeek!)
                    let rawWeekRange = startWeekStr + "-" + endWeekStr
                    print(self.prettifyWeek(week: rawWeekRange))
                    singleWeekRange = self.prettifyWeek(week: rawWeekRange)
                    
                    if tempKey == "" {
                        tempKey = singleWeekRange
                        weekSet.insert(key)
                    }
                    else if singleWeekRange != tempKey {
                        self.weekDict[tempKey] = weekSet
                        tempKey = singleWeekRange
                        weekSet = Set<String>()
                        weekSet.insert(key)
                    }
                    else if singleWeekRange == tempKey {
                        weekSet.insert(key)
                    }
                }
                self.weekDict[tempKey] = weekSet
                weekSet = Set<String>()
                
                for (key, _) in self.weekDict {
                    let weekSet = self.weekDict[key]
                    let weekSetCount = weekSet?.count
                    self.weeks.append(Weekly(wn: key, nodv: weekSetCount!, av: weekSet!))
                }
                
                self.weeks = self.weeks.sorted {
                    $0.weekName > $1.weekName
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                // debugging
                for i in self.weeks {
                    print("\(i.weekName!) - \(i.numberOfDaysVisited!) - \(i.allVisits)")
                }
                
            }
            else {
                print("==>DataSnapshot does not exist")
            }
        }
    }
    
    func loadYears() {
        var ref : DatabaseReference!
        
        ref = Database.database().reference()
        ref.child("PatientVisitsByDates/\(receivedData)").observeSingleEvent(of: .value) { (DataSnapshot) in
            if DataSnapshot.exists() {
                let dict = DataSnapshot.value as! [String : AnyObject]
                let sortedDict = dict.sorted {
                    $0.0 < $1.0
                }
                
                // extract [year: [set of dates in that year]
                // 2019 - ["2019-07-27", "2019-07-29", "2019-09-03", "2019-08-20",            "2019-08-26", "2019-08-22", "2019-08-31",                          "2019-07-28", "2019-08-23", "2019-08-21"]
                var tempKey = ""
                var yearSet = Set<String>()
                for (key, _) in sortedDict {
                    if tempKey == "" {
                        tempKey = String(key.prefix(4))
                        yearSet.insert(key)
                    }
                    else if key.prefix(4) != tempKey {
                        self.yearDict[tempKey] = yearSet
                        tempKey = String(key.prefix(4))
                        yearSet = Set<String>()
                        yearSet.insert(key)
                    }
                    else if key.prefix(4) == tempKey {
                        yearSet.insert(key)
                    }
                }
                self.yearDict[tempKey] = yearSet
                yearSet = Set<String>()
                
                for (key, _) in self.yearDict {
                    let yearSet = self.yearDict[key]
                    let yearSetCount = yearSet?.count
                    self.years.append(Yearly(yn: key, nodv: yearSetCount!,av: yearSet!))
                }
                
                self.years = self.years.sorted {
                    $0.yearName > $1.yearName
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                // debugging
                for i in self.years {
                    print("\(i.yearName!) - \(i.numberOfDaysVisited!) - \(i.allVisits)")
                }
                
            } else {
                print("==>DataSnapshot does not exist")
            }
        }
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
            
            var count = 0
            for (key, _) in self.monthDict {
                self.months.append(Monthly(mn: key, time: 0.0, tspv: 0.0, nodv: 0, av: Set<String>()))
                count += 1
            }
            self.months = self.months.sorted {
                $0.monthName > $1.monthName
            }
            
            for (key, value) in self.monthDict {
                print("\(key) - \(value)")
                self.updateEachObject(input: value)
            }
            
        }
    }
    
    func updateEachObject(input: Set<String>) {
        
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        for eachDate in input {
            ref.child("PatientVisitsByDates/\(receivedData)/\(eachDate)").observeSingleEvent(of: .value) { (DataSnapshot) in
                if DataSnapshot.exists() {
                    // get average of minutes per visit in one month (total minutes visited / number of days)
                    for eachObject in self.months {
                        if eachObject.monthName == eachDate.prefix(7) {
                            let visitPerMonth = self.monthDict[String(eachDate.prefix(7))]
                            // add "average minute per visit for each month"
                            eachObject.timeSpentPerVisit = (eachObject.totalTimeSpent / Double(visitPerMonth!.count))
                            // add ["2019-08-20", "2019-08-23", "2019-08-21", "2019-08-26", "2019-08-22", "2019-08-31"] to the Monthly object
                            eachObject.allVisits = visitPerMonth!
                            // add "Spent 6 days in total" for each month
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
        } else if tableTypes == "yearly" {
            return years.count
        } else if tableTypes == "weekly" {
            return weeks.count
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
        }
        else if tableTypes == "yearly" {
            let year = years[indexPath.row]
            cell.date.text = year.yearName
            if year.numberOfDaysVisited == 0 || year.numberOfDaysVisited == 1 {
                cell.daysLeft.text = "Spent \(year.numberOfDaysVisited!) day in total"
            }
            else {
                cell.daysLeft.text = "Spent \(year.numberOfDaysVisited!) days in total"
            }
        }
        else if tableTypes == "weekly" {
            let week = weeks[indexPath.row]
            cell.date.text = week.weekName
            if week.numberOfDaysVisited == 0 || week.numberOfDaysVisited == 1 {
                cell.daysLeft.text = "Spent \(week.numberOfDaysVisited!) day in total"
            }
            else {
                cell.daysLeft.text = "Spent \(week.numberOfDaysVisited!) days in total"
            }
        }
        else {
            let date = dates[indexPath.row]
            cell.date.text = date.date
            cell.daysLeft.text = date.daysAgo
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableTypes == "monthly") {
            let month = months[indexPath.row]
            // Convert set to array
            let setToArray = [String](month.allVisits)
            var data = tableTypes + "%" +  receivedData + "%"
            for eachDate in setToArray {
                if (eachDate == String(setToArray.last!)) {
                    data += eachDate
                }
                else {
                    data += eachDate + "%"
                }
            }
            self.passedData = data
            self.performSegue(withIdentifier: "next", sender: self)
            
        }
        else if tableTypes == "yearly" {
            let year = years[indexPath.row]
            let setToArray = [String](year.allVisits)
            var data = tableTypes + "%" + receivedData + "%"
            for eachDate in setToArray {
                if eachDate == String(setToArray.last!) {
                    data += eachDate
                } else {
                    data += eachDate + "%"
                }
            }
            self.passedData = data
            self.performSegue(withIdentifier: "next", sender: self)
        }
        else if tableTypes == "weekly" {
            let week = weeks[indexPath.row]
            let setToArray = [String](week.allVisits)
            var data = tableTypes + "%" + receivedData + "%" + week.weekName + "%"
            for eachDate in setToArray {
                if eachDate == String(setToArray.last!) {
                    data += eachDate
                } else {
                    data += eachDate + "%"
                }
            }
            self.passedData = data
            self.performSegue(withIdentifier: "next", sender: self)
        }
        else {
            let date = dates[indexPath.row]
            self.passedData = self.receivedData + "@" + date.rawDate
            self.performSegue(withIdentifier: "next", sender: self)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DetailViewController {
            vc.receivedData = self.passedData
        }
    }

}

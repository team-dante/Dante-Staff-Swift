//
//  DetailViewController.swift
//  Dante Staff
//
//  Created by Hung Phan on 9/1/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit
import Firebase
import Charts

class timeLineClass {
    var timelineStr : String!
    var order : Int!
    
    init(tl: String, o: Int) {
        timelineStr = tl
        order = o
    }
}

class RoomAndDuration {
    var room : String!
    var duration : Double!
    var order : Int!
    
    init(r: String, d: Double, o: Int) {
        if (r == "WR") {
            room = "Waiting Room"
        }
        else if (r == "LA1"){
            room = "Linear Accelerator 1"
        } else if (r == "TLA") {
            room = "Trilogy Linear Acc."
        } else if (r == "CT") {
            room = "CT Simulator"
        }
        duration = d
        order = o
    }
}
class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChartViewDelegate {
    
    var receivedData : String = ""
    var numberOfVisitPerRoom : [Int] = [0, 0, 0, 0]
    var details : [RoomAndDuration] = []
    var detailsMonthly : [RoomAndDuration] = []
    var timelineArr : [timeLineClass] = []
    var rooms : [String] = ["WR", "LA1", "TLA", "CT"]
    var timeSpent : [Double] = [0, 0, 0, 0]
    var toggle = true
    var tableTypes : String = ""

    @IBOutlet weak var mapAnnotation: UIView!
    @IBOutlet weak var questionMarkImageBtn: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBackground: UIView!
    @IBOutlet weak var chartView: BarChartView!
    @IBOutlet weak var backgroundChartView: UIView!
    @IBOutlet weak var totalTimeSpentLabel: UILabel!
    @IBOutlet weak var refresh: UIImageView!
    @IBOutlet weak var lastLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableTypes = receivedData.components(separatedBy: "%")[0]

        self.tableViewBackground.layer.cornerRadius = 10.0
        self.tableView.layer.cornerRadius = 10.0
        self.backgroundChartView.layer.cornerRadius = 10.0
        
        refresh.isUserInteractionEnabled = true
        refresh.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(refreshTapped)))
        
        // !!! Don't forget to open the idenity inspector of chartView
        // and set the class to BarChartView
        self.chartView.delegate = self
        
        // Modify xAxis's properties
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 15, weight: .ultraLight)
        xAxis.labelCount = 4
        xAxis.labelTextColor = UIColor.white
        xAxis.valueFormatter = IndexAxisValueFormatter(values: rooms)
        xAxis.granularity = 1
        xAxis.gridColor = UIColor.white
        
        
        // Modify leftAxis's properties
        let leftAxis = chartView.leftAxis
        leftAxis.labelTextColor = UIColor.white
        leftAxis.axisMinimum = 0.0
        leftAxis.gridColor = UIColor.white
        leftAxis.labelFont = .systemFont(ofSize: 15, weight: .ultraLight)
        
        // Modify rightAxis's properties
        let rightAxis = chartView.rightAxis
        rightAxis.labelTextColor = UIColor.white
        rightAxis.axisMinimum = 0.0
        rightAxis.gridColor = UIColor.white
        rightAxis.labelFont = .systemFont(ofSize: 15, weight: .ultraLight)
        
        let legendVar = chartView.legend
        legendVar.form = .circle
        legendVar.textColor = UIColor.white
        legendVar.enabled = false
        
        
        chartView.drawBarShadowEnabled = false
        chartView.animate(yAxisDuration: 2)
        chartView.borderColor = UIColor.white
        
        // adjust the height of the barchart to the view's height
        self.chartView.notifyDataSetChanged()

    }
    
    @objc func refreshTapped(_ recognizer: UITapGestureRecognizer) {
        if (tableTypes == "monthly") {
            self.detailsMonthly = [
                RoomAndDuration(r: "WR", d: 0.0, o: 0),
                RoomAndDuration(r: "LA1", d: 0.0, o: 1),
                RoomAndDuration(r: "TLA", d: 0.0, o: 2),
                RoomAndDuration(r: "CT",  d: 0.0, o: 3)
            ]
            timeSpent = [0, 0, 0, 0]
            numberOfVisitPerRoom = [0, 0, 0, 0]
            loadRoomAndMonth()
        } else {
            details = []
            timeSpent = [0, 0, 0, 0]
            self.loadRoomAndTime()
        }
        UIView.animate(withDuration: 1) {
            self.refresh.transform = self.refresh.transform.rotated(by: CGFloat.pi/1)
        }
    }
    
    @objc func popupAnnotation(_ recognizer: UITapGestureRecognizer) {
        if (toggle == true) {
            self.mapAnnotation.isHidden = false
            questionMarkImageBtn.image = UIImage(named: "ic_clear.png")
            toggle = false
        } else if (toggle == false) {
            self.mapAnnotation.isHidden = true
            questionMarkImageBtn.image = UIImage(named: "question?.png")
            toggle = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.mapAnnotation.isHidden = true
        self.mapAnnotation.layer.cornerRadius = 10.0
        self.questionMarkImageBtn.isUserInteractionEnabled = true
        self.questionMarkImageBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(popupAnnotation(_:))))
        
        // iPhone 8 - each view is 220
        if (UIScreen.main.bounds.height == 667.0) {
            for constraint in self.backgroundChartView.constraints {
                if constraint.identifier == "chartHeightConstraint" {
                    constraint.constant = 220
                }
            }
            
            for constraint in self.tableViewBackground.constraints {
                if constraint.identifier == "tableHeightConstraint" {
                    
                    constraint.constant = 220
                }
            }
        }
        
        // iPhone 8 Plus/ iPhone XS - each view is 260
        if (UIScreen.main.bounds.height == 736.0 || UIScreen.main.bounds.height == 812.0) {
            for constraint in self.backgroundChartView.constraints {
                if constraint.identifier == "chartHeightConstraint" {
                    constraint.constant = 260
                }
            }
            
            for constraint in self.tableViewBackground.constraints {
                if constraint.identifier == "tableHeightConstraint" {
                    
                    constraint.constant = 260
                }
            }
        }
        
        // update sublayouts
        self.backgroundChartView.layoutIfNeeded()
        self.tableViewBackground.layoutIfNeeded()
        
        // deselect selected row
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
        
        if (tableTypes == "monthly") {
            print("==>receivedDataFromDateVC=",receivedData)
            
            self.lastLabel.text = "Total Time Spent in This Month"
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.detailsMonthly = [
                RoomAndDuration(r: "WR", d: 0.0, o: 0),
                RoomAndDuration(r: "LA1", d: 0.0, o: 1),
                RoomAndDuration(r: "TLA", d: 0.0, o: 2),
                RoomAndDuration(r: "CT",  d: 0.0, o: 3)
            ]
            timeSpent = [0, 0, 0, 0]
            numberOfVisitPerRoom = [0, 0, 0, 0]
            loadRoomAndMonth()
        }
        else {
            
            print("==>receivedDataFromDateVC=",receivedData)
            
            self.tableView.delegate = self
            self.tableView.dataSource = self
            details = []
            self.loadRoomAndTime()
        }
    }
    
    func loadGraph(dataPoints: [String], values: [Double]) {
        chartView.noDataText = "No data for the chart."
        
        var dataEntries : [BarChartDataEntry] = []
        var valueColors = [UIColor]()
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
            valueColors.append(UIColor.white)
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Time spent in each room")
        // barChartDataset.colors = [UIColor.red,UIColor.orange,UIColor.green,UIColor.black,UIColor.blue]
        chartDataSet.colors = ChartColorTemplates.vordiplom()
        chartDataSet.highlightColor = UIColor.white
        chartDataSet.barBorderColor = UIColor.white
        chartDataSet.valueColors = valueColors
        chartDataSet.valueFont = UIFont(name: "HelveticaNeue-Medium", size: 17)!
        let chartData = BarChartData(dataSet: chartDataSet)
        chartView.data = chartData
    }
    
    func loadRoomAndMonth() {
        let receivedDataArr = receivedData.components(separatedBy: "%")
        self.dateLabel.text = "Report for \(self.prettifyMonth(input: String(receivedDataArr[2].prefix(7))))"
        var ref : DatabaseReference!
        ref = Database.database().reference()
        
        // retrieve all dates from receivedData
        var dateArray : [String] = []
        for i in 2..<receivedDataArr.count {
            dateArray.append(receivedDataArr[i])
        }
        
        // reverse sort the array to get the dates from latest to oldest
        dateArray = Array(dateArray.sorted().reversed())
        
        let dispatchGroup = DispatchGroup()
        for eachDate in dateArray {
            dispatchGroup.enter()
            ref.child("PatientVisitsByDates/\(receivedDataArr[1])/\(eachDate)").observeSingleEvent(of: .value) { (DataSnapshot) in
                if DataSnapshot.exists() {
                    let dict = DataSnapshot.value as! [String : AnyObject]

                    for (_, value) in dict {
                        if value["inSession"] as! Bool == false {
                            let hour = ((value["endTime"] as! Double - (value["startTime"] as! Double)) / 3600.0)
                            if (value["room"] as! String == "WR") {
                                self.timeSpent[0] = (self.timeSpent[0] + Double(hour))
                                self.detailsMonthly[0].duration = self.detailsMonthly[0].duration + hour
                                self.numberOfVisitPerRoom[0] = self.numberOfVisitPerRoom[0] + 1
                            } else if (value["room"] as! String == "LA1") {
                                self.timeSpent[1] = (self.timeSpent[1] + Double(hour))
                                self.detailsMonthly[1].duration = self.detailsMonthly[1].duration + hour
                                self.numberOfVisitPerRoom[1] = self.numberOfVisitPerRoom[1] + 1
                            } else if (value["room"] as! String == "TLA") {
                                self.timeSpent[2] = (self.timeSpent[2] + Double(hour))
                                self.detailsMonthly[2].duration = self.detailsMonthly[2].duration + hour
                                self.numberOfVisitPerRoom[2] = self.numberOfVisitPerRoom[2] + 1
                            } else if (value["room"] as! String == "CT") {
                                self.timeSpent[3] = (self.timeSpent[3] + Double(hour))
                                self.detailsMonthly[3].duration = self.detailsMonthly[3].duration + hour
                                self.numberOfVisitPerRoom[3] = self.numberOfVisitPerRoom[3] + 1
                            }
                            

                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                         } else {
                            let now = NSDate().timeIntervalSince1970
                            let hour = ((Double(now) - (value["startTime"] as! Double)) / 3600.0)
                            if (value["room"] as! String == "WR") {
                                self.timeSpent[0] = (self.timeSpent[0] + Double(hour))
                                self.detailsMonthly[0].duration = self.detailsMonthly[0].duration + hour
                                self.numberOfVisitPerRoom[0] = self.numberOfVisitPerRoom[0] + 1
                            } else if (value["room"] as! String == "LA1") {
                                self.timeSpent[1] = (self.timeSpent[1] + Double(hour))
                                self.detailsMonthly[1].duration = self.detailsMonthly[1].duration + hour
                                self.numberOfVisitPerRoom[1] = self.numberOfVisitPerRoom[1] + 1
                            } else if (value["room"] as! String == "TLA") {
                                self.timeSpent[2] = (self.timeSpent[2] + Double(hour))
                                self.detailsMonthly[2].duration = self.detailsMonthly[2].duration + hour
                                self.numberOfVisitPerRoom[2] = self.numberOfVisitPerRoom[2] + 1
                            } else if (value["room"] as! String == "CT") {
                                self.timeSpent[3] = (self.timeSpent[3] + Double(hour))
                                self.detailsMonthly[3].duration = self.detailsMonthly[3].duration + hour
                                self.numberOfVisitPerRoom[3] = self.numberOfVisitPerRoom[3] + 1
                            }
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                            
                        }
                    }
                } else {
                    print("==>DataSnapshot does not exist.")
                }
                // put dispatch at the end of the closure
                dispatchGroup.leave()
            }
        }
        
        // Execute code below only after Firebase is done processing data
        dispatchGroup.notify(queue: DispatchQueue.main) {
            print("All Done")
            print(self.timeSpent)
            self.loadGraph(dataPoints: self.rooms, values: self.timeSpent)
            var totalTimeSpentInMonth : Double = 0
            for i in self.timeSpent {
                totalTimeSpentInMonth += i
            }
            self.totalTimeSpentLabel.text = "\(round(100 * totalTimeSpentInMonth)/100) hr"
                        for i in 0..<self.detailsMonthly.count {
                            print("\(self.detailsMonthly[i].room! ) - \(String(describing: self.detailsMonthly[i].duration!) )")
                        }
                        print("##################")
                        for i in 0..<self.timeSpent.count {
                            print("\(self.timeSpent[i])")
                        }
                        print("[WR, LA1, TLA, CT]")
                        for i in 0..<self.numberOfVisitPerRoom.count {
                            print("\(self.numberOfVisitPerRoom[i])")
                        }
        }
    }
    
    func loadRoomAndTime() {
        
        let receivedDataArr = receivedData.components(separatedBy: "@")
        self.dateLabel.text = "Report for \(self.prettifyDate(date: receivedDataArr[1]))"
        var ref : DatabaseReference!
        ref = Database.database().reference()
        ref.child("PatientVisitsByDates/\(receivedDataArr[0])/\(receivedDataArr[1])").observeSingleEvent(of: .value) { (DataSnapshot) in
            if DataSnapshot.exists() {
                let dict = DataSnapshot.value as! [String : AnyObject]
                
                print("oldDict=>", dict)
                
                var newDict : [Int : AnyObject] = [:]
                
                for (_, value) in dict {
                    let startTimeKey = value["startTime"] as! Int
                    newDict[startTimeKey] = value
                }
                
                print("newDict=>", newDict)
                
                let sortedArrayTuple = newDict.sorted() { $0.key > $1.key }
                
                print("sortedDict=>", sortedArrayTuple)
                
                // dictionary cannot be sorted
                
                var count = 0
                
                for (_, value) in sortedArrayTuple {
                    
                    if (value["inSession"]! as! Bool == false) {
                        
//                      var rooms : [String] = ["WR", "LA1", "TLA", "CT"]
                        let minute = ((value["endTime"] as! Double - (value["startTime"] as! Double)) / 60.0)
                            if (value["room"] as! String == "WR") {
                                self.timeSpent[0] = (self.timeSpent[0] + Double(minute))
                            } else if (value["room"] as! String == "LA1") {
                                self.timeSpent[1] = (self.timeSpent[1] + Double(minute))
                            } else if (value["room"] as! String == "TLA") {
                                self.timeSpent[2] = (self.timeSpent[2] + Double(minute))
                            } else if (value["room"] as! String == "CT") {
                                self.timeSpent[3] = (self.timeSpent[3] + Double(minute))
                            }
                            for i in 0...3 {
                                print("..", self.timeSpent[i])
                            }
                        count += 1
                        self.details.append(RoomAndDuration(r: value["room"] as! String, d: minute, o: count))
                        
                        let startTime = value["startTime"] as! Double
                        let endTime = value["endTime"] as! Double
                        let startDate = NSDate(timeIntervalSince1970: startTime)
                        let endDate = NSDate(timeIntervalSince1970: endTime)
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "hh:mm a"
                        let startTimeStr = dateFormatter.string(from: startDate as Date)
                        let endTimeStr = dateFormatter.string(from: endDate as Date)
                        let timelineStr = "\(startTimeStr) - \(endTimeStr)"
                        self.timelineArr.append(timeLineClass(tl: timelineStr, o: count))
                        
                        self.details = self.details.sorted {
                            $0.order < $1.order
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            
                        }
                    }
                    else {
                            let now = NSDate().timeIntervalSince1970
                            let minute = ((Int(now) - (value["startTime"] as! Int)) / 60)
                            if (value["room"] as! String == "WR") {
                                self.timeSpent[0] = (self.timeSpent[0] + Double(minute))
                            } else if (value["room"] as! String == "LA1") {
                                self.timeSpent[1] = (self.timeSpent[1] + Double(minute))
                            } else if (value["room"] as! String == "TLA") {
                                self.timeSpent[2] = (self.timeSpent[2] + Double(minute))
                            } else if (value["room"] as! String == "CT") {
                                self.timeSpent[3] = (self.timeSpent[3] + Double(minute))
                            }
                            for i in 0...3 {
                                print("...", self.timeSpent[i])
                            }
                        
                        count += 1
                        self.details.append(RoomAndDuration(r: value["room"] as! String, d: -1.0, o: count))
                        
                        let startTime = value["startTime"] as! Double
                        let startDate = NSDate(timeIntervalSince1970: startTime)
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "hh:mm a"
                        let startTimeStr = dateFormatter.string(from: startDate as Date)
                        let timelineStr = "\(startTimeStr) - Present"
                        self.timelineArr.append(timeLineClass(tl: timelineStr, o: count))
                        
                        self.details = self.details.sorted {
                            $0.order < $1.order
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            } else {
                print("==>DataSnapshot does not exist.")
            }
            
            var displayTotalTime : Double = 0
            for i in 0...3 {
                displayTotalTime += self.timeSpent[i]
            }
//            String(Double(round(100 * detail.duration)/100)) + " min"
            self.totalTimeSpentLabel.text = "\(round(100 * displayTotalTime)/100) min"
                
            // loadGraph is called after timeSpent is filled with values.
            self.loadGraph(dataPoints: self.rooms, values: self.timeSpent)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableTypes == "monthly") {
            return detailsMonthly.count
        }
        return details.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "DetailTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DetailTableViewCell else {
            fatalError("==>The dequeued cell is not an instance of DateTableViewCell.")
        }
        
        
        if (tableTypes == "monthly") {
            let detailMonthly = detailsMonthly[indexPath.row]
            let numberOfVisit = numberOfVisitPerRoom[indexPath.row]
            cell.roomLabel.text = "\(detailMonthly.room!)"
            cell.durationMinuteLabel.text = String(Double(round(100 * detailMonthly.duration)/100)) + " hr"
//            let timeline = timelineArr[indexPath.row]
            if (numberOfVisit == 0 || numberOfVisit == 1) {
                cell.timeline.text = "Visited \(numberOfVisit) time"
            } else {
                cell.timeline.text = "Visited \(numberOfVisit) times"
            }
        } else {
            let detail = details[indexPath.row]
            cell.roomLabel.text = "\(details.count - indexPath.row). \(detail.room!)"
            if (detail.duration == -1.0) {
                cell.durationMinuteLabel.text = "Currently there"
            } else {
                cell.durationMinuteLabel.text = String(Double(round(100 * detail.duration)/100)) + " min"
            }
            let timeline = timelineArr[indexPath.row]
            cell.timeline.text = timeline.timelineStr
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "CustomHeaderDetailTableViewCell") as! CustomHeaderDetailTableViewCell
        headerView.autoresizingMask = []
        if tableTypes == "monthly" {
            headerCell.locationLabel.text = "List of All Locations"
            headerCell.timeLabel.text = "Total Time"
        }
        headerView.addSubview(headerCell)
        
        return headerView
    }
}

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

class RoomAndDuration {
    var room : String!
    var duration: Int!
    var startTime: Int!
    var endTime: Int!
    
    init(r: String, d: Int, s: Int, e: Int) {
        room = r
        duration = d
        startTime = s
        endTime = e
    }
}

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChartViewDelegate {
    
    var receivedData : String = ""
    var details = [RoomAndDuration]()
    
    // declare ref before viewDidLoad()
    var ref: DatabaseReference!

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBackground: UIView!
    @IBOutlet weak var chartView: BarChartView!
    @IBOutlet weak var backgroundChartView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init ref immediately
        ref = Database.database().reference()
        
        self.tableViewBackground.layer.cornerRadius = 10.0
        self.tableView.layer.cornerRadius = 10.0
        self.backgroundChartView.layer.cornerRadius = 10.0
        
        // !!! Don't forget to open the idenity inspector of chartView
        // and set the class to BarChartView
        self.chartView.delegate = self
        
        // Modify xAxis's properties
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 12)
        xAxis.labelCount = 4
        xAxis.labelTextColor = UIColor.white
        xAxis.gridColor = UIColor.white
        
        // Modify leftAxis's properties
        let leftAxis = chartView.leftAxis
        leftAxis.labelTextColor = UIColor.white
        leftAxis.axisMinimum = 0.0
        leftAxis.gridColor = UIColor.white
        
        // Modify rightAxis's properties
        let rightAxis = chartView.rightAxis
        rightAxis.labelTextColor = UIColor.white
        rightAxis.axisMinimum = 0.0
        rightAxis.gridColor = UIColor.white
        
        // Do not display legend
        chartView.legend.enabled = false
    
        chartView.drawBarShadowEnabled = false
        chartView.animate(yAxisDuration: 2)
        chartView.borderColor = UIColor.white
        
        // adjust the height of the barchart to the view's height
        self.chartView.notifyDataSetChanged()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("==>receivedDataFromDateVC=",receivedData)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // rows should not be clickable
        self.tableView.allowsSelection = false
        
        self.loadRoomAndTime()
    }
    
    func loadRoomAndTime() {
        let receivedDataArr = receivedData.components(separatedBy: "@")
        self.dateLabel.text = "Report for \(self.prettifyDate(date: receivedDataArr[1]))"
        
        ref.child("PatientVisitsByDates/\(receivedDataArr[0])/\(receivedDataArr[1])")
            .observeSingleEvent(of: .value) { (snapshot) in
            if let timeObjs = snapshot.value as? [String: Any] {
                for timeObj in timeObjs {
                    if let obj = timeObj.value as? [String: Any] {
                        let room = obj["room"] as! String
                        let inSession = obj["inSession"] as! Bool
                        let startTime = obj["startTime"] as! Int
                        var endTime = 0
                        var timeElapsed = 0
                        
                        // current room duration = now() - entry time
                        if inSession {
                            timeElapsed = Int(NSDate().timeIntervalSince1970) - startTime
                        } else {
                            endTime = obj["endTime"] as! Int
                            timeElapsed = endTime - startTime
                        }
                        // rooms may be repeated (patients may visit some rooms more than once)
                        self.details.append(RoomAndDuration(r: room, d: timeElapsed, s: startTime, e: endTime))
                    }
                }
                // sort array of Room and Duration by start time
                self.details.sort(by: {$0.startTime < $1.startTime})
                // load graph
                self.loadGraph(dataPoints: self.details)
                // reload table
                self.tableView.reloadData()
            } else {
                self.details.removeAll()
                self.tableView.reloadData()
            }
        }
    }
    
    func loadGraph(dataPoints: [RoomAndDuration]) {
        // defaultdict
        var dict: [String:[Int]] = [:]
        // dataPoints param is an array of RoomAndDuration objects that potentially have duplicate rooms;
        // use defaultdict to combine dups; e.g. [CT: [1230, 1000]] (in seconds)
        for data in dataPoints {
            dict[data.room, default: []].append(data.duration)
        }
        // add up all time tracking data for that room of that single day
        // ex. [CTRoom: 2230]
        let roomTuple = dict.map { (i) in
            return (i.key, i.value.reduce(0,+))
        }
        // change x-axis to room names
        self.chartView.noDataText = "No data for the chart."
        // dump time elapsed into bar charts; assign indexes to x-axis temporaily
        let dataEntries = (0..<roomTuple.count).map { (i) -> BarChartDataEntry in
            return BarChartDataEntry(x: Double(i), y: Double(roomTuple[i].1)/60.0)
        }
        // set x-axis to room strings
        let xAxis = self.chartView.xAxis
        xAxis.valueFormatter = IndexAxisValueFormatter(values: roomTuple.map { i in return i.0})
        xAxis.granularity = 1

        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Time spent in each room")
        chartDataSet.colors = ChartColorTemplates.vordiplom()
        chartDataSet.highlightColor = UIColor.white
        chartDataSet.barBorderColor = UIColor.white
        chartDataSet.valueFont = UIFont.systemFont(ofSize: 12)
        let chartData = BarChartData(dataSet: chartDataSet)
        chartView.data = chartData
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return details.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // if cell exists and/or dequeuesable: return cell
        // otherwise return empty cell (nothing)
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell", for: indexPath) as? DetailTableViewCell {
            let detail = details[indexPath.row]
            cell.roomLabel.text = "\(details.count - indexPath.row). \(detail.room!)"
            
            // endTime = 0 means the patient is currently at that particular room
            if detail.endTime == 0 {
                cell.durationMinuteLabel.text = "In Session"
            } else {
                let timeSpent = (Double(detail.duration) / 60.0 * 100).rounded() / 100
                cell.durationMinuteLabel.text = "\(timeSpent) min"
            }
            return cell
        }
        return UITableViewCell()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // avoid memory leak; remove all data when you're about to exit this view
        self.details.removeAll()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "CustomHeaderDetailTableViewCell") as! CustomHeaderDetailTableViewCell
        headerView.autoresizingMask = []
        headerView.addSubview(headerCell)
        return headerView
    }
    
//    // use at your discretion: generate random colors to display time tracking data for each room
//    private func colorsOfCharts(numberOfColor: Int) -> [UIColor] {
//        var colors = [UIColor]()
//        for _ in 0..<numberOfColor {
//            let red = Double(arc4random_uniform(256))
//            let green = Double(arc4random_uniform(256))
//            let blue = Double(arc4random_uniform(256))
//            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
//            colors.append(color)
//        }
//        return colors
//    }
}

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
    var duration : Int!
    
    init(r: String, d: Int) {
        room = r
        duration = d
    }
}
class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChartViewDelegate {
    
    var receivedData : String = ""
    var details : [RoomAndDuration] = []
    var rooms : [String] = ["Waiting\nRoom", "Linear\nAccelerator 1", "Trilogy\nLinear\nAccelerator", "CT\nSimulator"]
    var timeSpent : [Double] = [23, 0, 10, 60]

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBackground: UIView!
    @IBOutlet weak var chartView: BarChartView!
    @IBOutlet weak var backgroundChartView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableViewBackground.layer.cornerRadius = 10.0
        self.tableView.layer.cornerRadius = 10.0
        self.backgroundChartView.layer.cornerRadius = 10.0
        
        // !!! Don't forget to open the idenity inspector of chartView
        // and set the class to BarChartView
        self.chartView.delegate = self
        
        // Modify xAxis's properties
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 13)
        xAxis.labelCount = 4
        xAxis.labelTextColor = UIColor.white
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: rooms)
        chartView.xAxis.granularity = 1
        
        // Modify leftAxis's properties
        let leftAxis = chartView.leftAxis
        leftAxis.labelTextColor = UIColor.white
        leftAxis.axisMinimum = 0.0
        
        // Modify rightAxis's properties
        let rightAxis = chartView.rightAxis
        rightAxis.labelTextColor = UIColor.white
        rightAxis.axisMinimum = 0.0
        
        let legendVar = chartView.legend
        legendVar.form = .circle
        legendVar.textColor = UIColor.white
        
        
        chartView.drawBarShadowEnabled = false
        chartView.animate(yAxisDuration: 2)
        chartView.borderColor = UIColor.white
        
        loadGraph(dataPoints: rooms, values: timeSpent)
        
        // adjust the height of the barchart to the view's height
        chartView.notifyDataSetChanged()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // deselect selected row
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
        
        print("==>receivedDataFromDateVC=",receivedData)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        details = []
        self.loadRoomAndTime()
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
        chartDataSet.barShadowColor = UIColor.white
        chartDataSet.barBorderColor = UIColor.white
        chartDataSet.valueColors = valueColors
        let chartData = BarChartData(dataSet: chartDataSet)
        chartView.data = chartData
    }
    
    func loadRoomAndTime() {
        
        let receivedDataArr = receivedData.components(separatedBy: "@")
        self.dateLabel.text = "Report for \(self.prettifyDate(date: receivedDataArr[1]))"
        var ref : DatabaseReference!
        ref = Database.database().reference()
        ref.child("PatientVisitsByDates/\(receivedDataArr[0])/\(receivedDataArr[1])").observeSingleEvent(of: .value) { (DataSnapshot) in
            if DataSnapshot.exists() {
                let dict = DataSnapshot.value as! [String : AnyObject]
                for (_, value) in dict {
                    if (value["inSession"]! as! Bool == false) {
                        
//                      var rooms : [String] = ["WR", "LA1", "TLA", "CT"]
                        let minute = ((value["endTime"] as! Int - (value["startTime"] as! Int)) / 60)
                        if (value["room"] as! String == "WR") {
                            self.timeSpent[0] += Double(minute)
                        } else if (value["room"] as! String == "LA1") {
                            self.timeSpent[1] += Double(minute)
                        } else if (value["room"] as! String == "TLA") {
                            self.timeSpent[2] += Double(minute)
                        } else if (value["room"] as! String == "CT") {
                            self.timeSpent[3] += Double(minute)
                        }
                        
                        self.details.append(RoomAndDuration(r: value["room"] as! String, d: minute))
                        self.details = self.details.sorted {
                            $0.duration < $1.duration
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                    else {
                        self.details.append(RoomAndDuration(r: value["room"] as! String, d: -1))
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            } else {
                print("==>DataSnapshot does not exist.")
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return details.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "DetailTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DetailTableViewCell else {
            fatalError("==>The dequeued cell is not an instance of DateTableViewCell.")
        }

        let detail = details[indexPath.row]
        cell.roomLabel.text = detail.room
        if (detail.duration == -1) {
            cell.durationMinuteLabel.text = "Currently there"
        } else {
            cell.durationMinuteLabel.text = String(detail.duration) + " minutes"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "CustomHeaderDetailTableViewCell") as! CustomHeaderDetailTableViewCell
        headerView.autoresizingMask = []
        headerView.addSubview(headerCell)
        return headerView
    }
}

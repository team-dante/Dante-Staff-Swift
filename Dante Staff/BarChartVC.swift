//
//  BarChartVC.swift
//  Dante Staff
//
//  Created by Hung Phan on 8/3/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit
import Charts

class BarChartVC: UIViewController, ChartViewDelegate {
    
    var months: [String]! = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
    
    @IBOutlet weak var chartView: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Save", style: .done, target: self, action: #selector(self.action(sender:)))
        
        chartView.delegate = self
        
        // x Axis's label
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 15)
        xAxis.labelCount = 12
        
        chartView.drawValueAboveBarEnabled = false
        chartView.animate(yAxisDuration: 2)
        
        setChart(dataPoints: months, values: unitsSold)
        
//        let limitLine = ChartLimitLine(limit: 10.0, label: "Goal")
//        chartView.rightAxis.addLimitLine(limitLine)
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        chartView.noDataText = "You need to provide data for the chart."
        
        // for a chart to display data, we need to create a BarChartData object and set it as chartView's data attribute
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            // x = 0, 1, 2, 3, ...
            // y = 20.0, 4.0, ...
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Number of patients treated per month")
        chartDataSet.colors = ChartColorTemplates.vordiplom()
        let chartData = BarChartData(dataSet: chartDataSet)
        chartView.data = chartData
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        NSLog("chartValueSelected");
    }
    
    @objc func action(sender: UIBarButtonItem) {
        //Create the UIImage
        UIGraphicsBeginImageContext(chartView.frame.size)
        chartView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //Save it to the camera roll
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        
        let alert = UIAlertController(title: "This graph is saved in your Camera Roll.", message: "", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
}




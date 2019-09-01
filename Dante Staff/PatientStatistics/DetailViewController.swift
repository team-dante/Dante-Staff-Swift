//
//  DetailViewController.swift
//  Dante Staff
//
//  Created by Hung Phan on 9/1/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit
import Firebase

class RoomAndDuration {
    var room : String!
    var duration : Int!
    
    init(r: String, d: Int) {
        room = r
        duration = d
    }
}
class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var receivedData : String = ""
    var details : [RoomAndDuration] = []

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBackground: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableViewBackground.layer.cornerRadius = 30.0
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
                        self.details.append(RoomAndDuration(r: value["room"] as! String, d: ((value["endTime"] as! Int - (value["startTime"] as! Int)) / 60)))
                        self.details = self.details.sorted {
                            $0.duration < $1.duration
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                    else {
                        print(value["room"]!!)
                        print("Currently inside")
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
            cell.durationMinuteLabel.text = "Currently inside"
        } else {
            cell.durationMinuteLabel.text = String(detail.duration) + " minutes"
        }
        
        return cell
    }
}

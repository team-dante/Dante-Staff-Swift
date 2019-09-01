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
    var date : String!
    var daysAgo : String!
    var daysAgoSortedInt : Int!
    
    init(d : String, dA: String) {
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
    var dates : [DateCustom] = []

    @IBOutlet weak var tableBackground: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableBackground.layer.cornerRadius = 30.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
        
        print("==>receivedData=", receivedData)
        
        // load data to table
        self.tableView.delegate = self
        self.tableView.dataSource = self
        dates = []
        loadDates()
    }
    
    func loadDates() {
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        
        ref.child("PatientVisitsByDates/\(receivedData)").observeSingleEvent(of: .value) { (DataSnapshot) in
            if DataSnapshot.exists() {
                let dict = DataSnapshot.value as! [String : AnyObject]
                for (key, _) in dict {
                    let prettifiedDate = self.prettifyDate(date: key)
                    let daysAgo = self.daysAgoFunc(start: key)
                    self.dates.append(DateCustom(d: prettifiedDate, dA: daysAgo))
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
        self.performSegue(withIdentifier: "next", sender: self)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

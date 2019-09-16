//
//  PatientViewController.swift
//  Dante Staff
//
//  Created by Hung Phan on 8/30/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit
import Firebase

class Patient {
    var patientName : String!
    var patientPhoneNum : String!
    
    init(name: String, phoneNum: String) {
        patientName = name
        patientPhoneNum = phoneNum
    }
}

class PatientViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var refresh: UIImageView!
    var ref: DatabaseReference!

    var patients : [Patient] = []
    var passedData : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

        backgroundView.layer.cornerRadius = 10.0
        self.tableView.layer.cornerRadius = 10.0
        
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        
        refresh.isUserInteractionEnabled = true
        refresh.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(refreshTapped)))
    }
    
    @objc func refreshTapped(_ recognizer: UITapGestureRecognizer) {
        self.reload()
        UIView.animate(withDuration: 1) {
            self.refresh.transform = self.refresh.transform.rotated(by: CGFloat.pi/1)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
        
        self.reload()
        
    }
    
    // MARK: - Table view data source
    func reload() {
        patients = []
        loadPatients()
    }
    
    func loadPatients() {
        ref.child("Patients").observeSingleEvent(of: .value) { (DataSnapshot) in
            if DataSnapshot.exists() {
                let dict = DataSnapshot.value as? [String : AnyObject]
                for (_, value) in dict! {
                    let fullName = "\(value["firstName"] as! String) \(value["lastName"] as! String)"
                    let phoneNumber = value["patientPhoneNumber"] as! String
                    self.patients.append(Patient(name: fullName, phoneNum: phoneNumber))
                }
                // these lines make sure all patients are appended to the patients array
                self.patients.sort(by: {$0.patientName < $1.patientName} )
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            else {
                print("==>DataSnapshot is empty.")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return patients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "PatientTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PatientTableViewCell else {
            fatalError("==>The dequeued cell is not an instance of PatientTableViewCell.")
        }
        // fetch patient from patients array
        let patient = patients[indexPath.row]
        cell.patientName.text = patient.patientName
        cell.patientPhoneNumber.text = patient.patientPhoneNum
        
        //         Configure the cell...
        cell.backgroundColor = UIColor.clear
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numberOfSections = 0
        
        if self.patients.count == 0 {
            let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: tableView.frame.size.height))
            emptyLabel.text = "No Patient Visit History"
            emptyLabel.textColor = .white
            emptyLabel.textAlignment = .center
            tableView.backgroundView = emptyLabel
            tableView.separatorStyle = .none
        } else {
            tableView.separatorStyle = .singleLine
            numberOfSections = 1
            tableView.backgroundView = nil
        }
        
        return numberOfSections
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let patient = patients[indexPath.row]
        self.passedData = patient.patientPhoneNum
        self.performSegue(withIdentifier: "patientDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! DateViewController
        vc.receivedData = self.passedData
    }
}

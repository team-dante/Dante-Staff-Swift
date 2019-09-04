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
    
    var patients : [Patient] = []
    var passedData : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundView.layer.cornerRadius = 10.0
        self.tableView.layer.cornerRadius = 10.0
        
        tableView.backgroundColor = UIColor.clear

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
        self.tableView.delegate = self
        self.tableView.dataSource = self
        patients = []
        loadPatients()
    }
    
    func loadPatients() {
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        
        ref.child("Patients").observeSingleEvent(of: .value) { (DataSnapshot) in
            if DataSnapshot.exists() {
                let dict = DataSnapshot.value as? [String : AnyObject]
                for (_, value) in dict! {
                    let fullName = "\(value["firstName"] as! String) \(value["lastName"] as! String)"
                    let phoneNumber = value["patientPhoneNumber"] as! String
                    self.patients.append(Patient(name: fullName, phoneNum: phoneNumber))
                    // these lines make sure all patients are appended to the patients array
                    self.patients = self.patients.sorted() {
                        $0.patientName < $1.patientName
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
            else {
                print("==>DataSnapshot is empty.")
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let patient = patients[indexPath.row]
        self.passedData = patient.patientPhoneNum
        self.performSegue(withIdentifier: "patientDetail", sender: self)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! DateViewController
        vc.receivedData = self.passedData
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
}

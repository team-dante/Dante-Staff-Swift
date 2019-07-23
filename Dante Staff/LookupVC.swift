//
//  LookupVC.swift
//  Dante Staff
//
//  Created by Hung Phan on 7/20/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit
import FirebaseDatabase

class LookupVC: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        self.noUserFound.text = ""
        self.noUserFound.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.noUserFound.text = ""
        self.noUserFound.isHidden = true
    }

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var lookupBtn: UIButton!
    
    var dataPassed = ["":""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
        let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        glassIconView?.tintColor = UIColor.white
        
        let clearButton = textFieldInsideSearchBar?.value(forKey: "clearButton") as! UIButton
        clearButton.setImage(UIImage(named: "ic_clear"), for: .normal)
        clearButton.tintColor = .white
        
        lookupBtn.layer.cornerRadius = 10.0
        
        self.addDoneButtonOnKeyboard()
        
    }
    
    @IBOutlet weak var noUserFound: UILabel!
    
    @IBAction func lookupBtnPressed(_ sender: Any) {
        ViewController().showSpinner(onView: self.view)
        
        Database.database().reference().child("Patients")
            .observeSingleEvent(of: .value, with: { (snapshot) in
                for eachPatient in snapshot.children {
                    let snap = eachPatient as! DataSnapshot
                    let dict = snap.value as! [String: String]
                    if (dict["patientPhoneNumber"] == self.searchBar.text) {
                        self.dataPassed = dict
                        print("===>\(self.dataPassed)")
                        self.searchBar.text = ""
                        self.performSegue(withIdentifier: "lookupvc", sender: self)
                    }
                }
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.searchBar.text = ""
                self.noUserFound.isHidden = false
                self.noUserFound.text = "This phone number does not exist."
                ViewController().removeSpinner()
            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? DisplayAccVC
        vc!.dataReceived = self.dataPassed
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        searchBar.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction(){
        searchBar.resignFirstResponder()
    }

}


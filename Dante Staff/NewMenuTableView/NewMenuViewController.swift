//
//  NewMenuViewController.swift
//  Dante Staff
//
//  Created by Hung Phan on 9/8/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import NavigationDrawer

class MenuImageName {
    var leftImage : String!
    var rightImage : String!
    var leftLabel : String!
    var rightLabel : String!
    
    init(li1 : String, li2: String, ll: String, rl: String) {
        leftImage = li1
        rightImage = li2
        leftLabel = ll
        rightLabel = rl
    }
}

class NewMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate {
    
    var rows : [MenuImageName] = [
        MenuImageName(li1: "broadcast-icon", li2: "lookup-icon", ll: "Broadcast\nMy Location", rl: "Look up\nPatient Account"),
        MenuImageName(li1: "qr-code-icon", li2: "stat-icon", ll: "Display\nPatient Location", rl: "Display\nPatient Statistics"),
        MenuImageName(li1: "create-acc-icon", li2: "feedback-icon", ll: "Create\nPatient Account", rl: "Feedback"),
    ]
    
    let interactor = Interactor()
    
    @IBOutlet weak var staffLastName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //3. Add a Pan Gesture to slide the menu from Certain Direction
    @IBAction func edgePanGesture(_ sender: UIScreenEdgePanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        let progress = MenuHelper.calculateProgress(translationInView: translation, viewBounds: view.bounds, direction: .Right)
        
        MenuHelper.mapGestureStateToInteractor(
            gestureState: sender.state,
            progress: progress,
            interactor: interactor){
                self.performSegue(withIdentifier: "showSlidingMenu", sender: nil)
        }
    }
    
    //4. Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? SlidingViewVC {
            // extension NewMenuViewController: UIViewControllerTransitioningDelegate { ... }  !!! change the extension name
            destinationViewController.transitioningDelegate = self
            destinationViewController.interactor = self.interactor
            //            destinationViewController.mainVC = self
        }
    }

    @objc func panAction(sender: UIScreenEdgePanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        let progress = MenuHelper.calculateProgress(translationInView: translation, viewBounds: view.bounds, direction: .Right)
        
        MenuHelper.mapGestureStateToInteractor(
            gestureState: sender.state,
            progress: progress,
            interactor: interactor){
                self.performSegue(withIdentifier: "showSlidingMenu", sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifider = "rowCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifider, for: indexPath) as? NewMenuTableViewCell else {
            fatalError("==>The dequeued cell is not an instance of PatientTableViewCell.")
        }
        
        let row = rows[indexPath.row]
        cell.leftImage.image = UIImage(named: row.leftImage)
        cell.rightImage.image = UIImage(named: row.rightImage)
        cell.leftButton.tag = indexPath.row
        cell.leftButton.layer.cornerRadius = 10.0
        cell.leftLabel.text = row.leftLabel
        cell.leftView.layer.cornerRadius = 10.0
        cell.leftButton.addTarget(self, action: #selector(next(_:)), for: .touchUpInside)
        cell.rightButton.tag = indexPath.row + 10
        cell.rightButton.layer.cornerRadius = 10.0
        cell.rightView.layer.cornerRadius = 10.0
        cell.rightLabel.text = row.rightLabel
        cell.rightButton.addTarget(self, action: #selector(next(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func next(_ sender: UIButton) {

        let animator = UIViewPropertyAnimator(duration: 0.1, curve: .easeInOut) {
            sender.backgroundColor = UIColor.white
        }
        // start the animator
        animator.startAnimation()
        // return back to the original color after flashing
        animator.addCompletion({ (position) in
            sender.backgroundColor = UIColor.clear
        })

        if (sender.tag == 0) {
            if UIScreen.main.bounds.width == 375 || UIScreen.main.bounds.width == 414 {
                let backItem = UIBarButtonItem()
                backItem.title = "Stop"
                navigationItem.backBarButtonItem = backItem
                self.performSegue(withIdentifier: "goToBroadcast", sender: self)
            }
        } else if sender.tag == 10 {
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
//            self.performSegue(withIdentifier: "lookupAcc", sender: self)
        } else if sender.tag == 1 {
            if UIScreen.main.bounds.width == 375 || UIScreen.main.bounds.width == 414 {
                let backItem = UIBarButtonItem()
                backItem.title = "Back"
                navigationItem.backBarButtonItem = backItem
                self.performSegue(withIdentifier: "patientMap", sender: self)
            }
        } else if sender.tag == 11 {
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            self.performSegue(withIdentifier: "goToStats", sender: self)
        } else if sender.tag == 2 {
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            self.performSegue(withIdentifier: "createAcc", sender: self)
        } else if sender.tag == 12 {
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            self.performSegue(withIdentifier: "goToFeedback", sender: self)
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // allow sliding left from the left edge of the screen
        let panGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(panAction(sender:)))
        panGesture.edges = .left
        view.addGestureRecognizer(panGesture)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        rows = [
            MenuImageName(li1: "broadcast-icon", li2: "lookup-icon", ll: "Broadcast\nMy Location", rl: "Look up\nPatient Account"),
            MenuImageName(li1: "qr-code-icon", li2: "stat-icon", ll: "Display\nPatient Location", rl: "Display\nPatient Statistics"),
            MenuImageName(li1: "create-acc-icon", li2: "feedback-icon", ll: "Create\nPatient Account", rl: "Feedback"),
        ]
        
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Hide the Navigation Bar
        // Set login page's seugue to navigation control, not the main menu page
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = Auth.auth().currentUser {
                let phoneNum = user.email!.split(separator: "@")[0]
                Database.database().reference().child("staffs").observeSingleEvent(of: .value, with: { (snapshot) in
                    for eachDoctor in snapshot.children.allObjects as! [DataSnapshot] {
                        let dict = eachDoctor.value as? [String : String] ?? [:]
                        if (String(dict["phoneNum"]!) == String(phoneNum)) {
                            self.staffLastName.text = "Welcome, Staff \(dict["lastName"] ?? "Error!")"
                            // self.staffLastName.text = "Welcome, Staff AppleIphone11New" -> cuts off at 1... for 375 screen and no cut off for 414 screen
                        }
                    }
                }) { (error) in
                    print("=====>", error.localizedDescription)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        // Show the Navigation Bar
        // Set login page's seugue to navigation control, not the main menu page
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
    }
    
}

//5. Exten BaseVC
extension NewMenuViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentMenuAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissMenuAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}



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

// replace class if you want
struct MenuItem {
    var iconImg: String
    var description: String
    var segueID: String
}

class NewMenuViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    // list all menu items here
    var menuItems: [MenuItem] = [
        MenuItem(iconImg: "broadcast-icon", description: "Broadcast My Location", segueID: "goToBroadcast"),
        MenuItem(iconImg: "lookup-icon", description: "Look up Patient Account", segueID: "lookupAcc"),
        MenuItem(iconImg: "qr-code-icon", description: "Display Patient Location", segueID: "patientMap"),
        MenuItem(iconImg: "stat-icon", description: "Display Patient Statistics", segueID: "goToStats"),
        MenuItem(iconImg: "create-acc-icon", description: "Create Patient Account", segueID: "createAcc"),
        MenuItem(iconImg: "feedback-icon", description: "Feedback", segueID: "goToFeedback"),
    ]
    // cell's gap should be 20.0
    let sectionInsets = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
    let itemPerRow: CGFloat = 2 // 2 items per row
    
    let interactor = Interactor()
    
    @IBOutlet weak var staffLastName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // allow sliding left from the left edge of the screen
        let panGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(panAction(sender:)))
        panGesture.edges = .left
        view.addGestureRecognizer(panGesture)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Hide the Navigation Bar
        // Set login page's seugue to navigation control, not the main menu page
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        // deselect all collectionViewCells
        if let indexPath = collectionView.indexPathsForSelectedItems {
            for item in indexPath {
                collectionView.deselectItem(at: item, animated: false)
            }
        }
        
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuCollectionViewCell", for: indexPath) as? MenuCollectionViewCell {
            let menuItem = self.menuItems[indexPath.item]
            cell.iconImg.image = UIImage(named: menuItem.iconImg)
            cell.iconLabel.text = menuItem.description
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // check if menuItems is fully loaded ( > 0)
        if self.menuItems.count > 0 {
            let menuItem = self.menuItems[indexPath.item]
            if let cell = collectionView.cellForItem(at: indexPath) as? MenuCollectionViewCell {
                
                // when selected, darken the background color of a cell
                let backgroundView = UIView()
                backgroundView.layer.cornerRadius = 10.0
                backgroundView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
                cell.selectedBackgroundView = backgroundView
            }
            self.performSegue(withIdentifier: menuItem.segueID, sender: nil)
        }
    }
    
    // ------------ Layout Delegate Methods --------------
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemPerRow + 1)
        
        // 2 items per row; 3 paddings across a row; a cell's width = (total width - 3 gaps) / 2.0
        let width = (collectionView.frame.width - paddingSpace) / 2.0
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    // ------------ End of Layout Delegate --------------
    
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

//
//  SlidingViewVC.swift
//  Dante Staff
//
//  Created by Hung Phan on 7/28/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit
import NavigationDrawer
import FirebaseAuth

class SlidingViewVC: UIViewController {
    
    var interactor:Interactor? = nil
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setNeedsStatusBarAppearanceUpdate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // Handle gesture

    @IBAction func handleGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        let progress = MenuHelper.calculateProgress(translationInView: translation, viewBounds: view.bounds, direction: .Left)
        
        MenuHelper.mapGestureStateToInteractor(
            gestureState: sender.state,
            progress: progress,
            interactor: interactor){
                self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func homeBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func logOutBtnPressed(_ sender: Any) {
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "signout", sender: self)
    }
    
    
}

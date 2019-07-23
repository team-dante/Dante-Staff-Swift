//
//  LookupVC.swift
//  Dante Staff
//
//  Created by Hung Phan on 7/20/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit

class LookupVC: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var lookupBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
        let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        glassIconView?.tintColor = UIColor.white
        
//        if let clearButton = searchBar.value(forKey: "clearButton") as? UIButton {
//            let templateImage = clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
//            clearButton.setImage(templateImage, for: .normal)
//            
//            clearButton.tintColor = .red
//        }
        
        lookupBtn.layer.cornerRadius = 10.0
        
        self.addDoneButtonOnKeyboard()
        
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


//
//  extensions.swift
//  Dante Staff
//
//  Created by Xinhao Liang on 7/24/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import Foundation
import UIKit

var vSpinner : UIView?
extension UIViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}

class CustomTextField: UITextField {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.gray.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
        self.leftView =  UIView(frame: CGRect(x: 0, y: 0, width: 5, height: self.frame.height))
        self.leftViewMode = .always
        self.layer.cornerRadius = 10.0
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        self.layer.shadowRadius = 0.5
        self.layer.shadowOpacity = 0.5
    }
}

class CustomFieldRounded: UITextField {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.layer.cornerRadius = 5.0

        let leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 12.0, height: 20.0))
        self.leftView = leftView
        self.leftViewMode = .always
        self.layer.masksToBounds = true
    }
}

class CustomButton: UIButton {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        self.layer.shadowRadius = 0.5
        self.layer.shadowOpacity = 0.5
    }
}



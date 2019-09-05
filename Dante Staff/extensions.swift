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
    
    func prettifyDate(date: String) -> String {
        let dateArr = date.components(separatedBy: "-")
        
        var month : String = ""
        
        switch dateArr[1] {
        case "01":
            month = "January"
        case "02":
            month = "Febuary"
        case "03":
            month = "March"
        case "04":
            month = "April"
        case "05":
            month = "May"
        case "06":
            month = "June"
        case "07":
            month = "July"
        case "08":
            month = "August"
        case "09":
            month = "September"
        case "10":
            month = "October"
        case "11":
            month = "November"
        case "12":
            month = "December"
        default:
            month = "N/A"
            break
        }
        
        let newDate = month + " "  + dateArr[2] + ", " + dateArr[0]
        
        return newDate
    }
    
    func daysAgoFunc(start: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let startDate : Date = dateFormatter.date(from: start)!
        let currentDateString = dateFormatter.string(from: Date())
        let currentDate : Date = dateFormatter.date(from: currentDateString)!
        
        let cal = NSCalendar.current
        let calComponents : Set<Calendar.Component> = [.day]
        let components = cal.dateComponents(calComponents, from: startDate, to: currentDate)
        
        let arr = String(describing: components).components(separatedBy: " ")
        
        return arr[1]
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



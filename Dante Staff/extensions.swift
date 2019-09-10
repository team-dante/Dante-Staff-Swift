//
//  extensions.swift
//  Dante Staff
//
//  Created by Xinhao Liang on 7/24/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import Foundation
import UIKit


extension Date {
    var startOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 0, to: sunday)
    }
    
    var endOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 6, to: sunday)
    }
}

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
    
    func prettifyRoom(room: String) -> String {
        switch room {
        case "LA1":
            return "Linear Accelerator 1"
        case "TLA":
            return "Trilogy Linear Acc."
        case "CT":
            return "CT Simulator"
        case "WR":
            return "Waiting Room"
        default:
            return ""
        }
    }
    
    func prettifyWeek(week: String) -> String {
        let weekArr = week.components(separatedBy: "-")
        
        var month1 : String = ""
        
        switch weekArr[1] {
        case "01":
            month1 = "Jan"
        case "02":
            month1 = "Feb"
        case "03":
            month1 = "Mar"
        case "04":
            month1 = "Apr"
        case "05":
            month1 = "May"
        case "06":
            month1 = "Jun"
        case "07":
            month1 = "Jul"
        case "08":
            month1 = "Aug"
        case "09":
            month1 = "Sep"
        case "10":
            month1 = "Oct"
        case "11":
            month1 = "Nov"
        case "12":
            month1 = "Dec"
        default:
            month1 = "N/A"
            break
        }
        
        var month2 : String = ""
        
        switch weekArr[4] {
        case "01":
            month2 = "Jan"
        case "02":
            month2 = "Feb"
        case "03":
            month2 = "Mar"
        case "04":
            month2 = "Apr"
        case "05":
            month2 = "May"
        case "06":
            month2 = "Jun"
        case "07":
            month2 = "Jul"
        case "08":
            month2 = "Aug"
        case "09":
            month2 = "Sep"
        case "10":
            month2 = "Oct"
        case "11":
            month2 = "Nov"
        case "12":
            month2 = "Dec"
        default:
            month2 = "N/A"
            break
        }
        
        var newWeek = ""
        if month1 == month2 {
            newWeek = month1 + " "  + weekArr[2] + " - " + weekArr[5]
        }
        else {
            newWeek = month1 + " "  + weekArr[2] + " - " + month2 + " " + weekArr[5]
        }
        
        return newWeek
    }
    
    func prettifyMonth(input: String) -> String {
        let inputArr = input.components(separatedBy: "-")
        
        var month1 : String = ""
        
        switch inputArr[1] {
        case "01":
            month1 = "Jan"
        case "02":
            month1 = "Feb"
        case "03":
            month1 = "Mar"
        case "04":
            month1 = "Apr"
        case "05":
            month1 = "May"
        case "06":
            month1 = "Jun"
        case "07":
            month1 = "Jul"
        case "08":
            month1 = "Aug"
        case "09":
            month1 = "Sep"
        case "10":
            month1 = "Oct"
        case "11":
            month1 = "Nov"
        case "12":
            month1 = "Dec"
        default:
            month1 = "N/A"
            break
        }
        
        let newMonth = month1 + " " + inputArr[0]
        
        return newMonth
    }
    
    func prettifyDate(date: String) -> String {
        let dateArr = date.components(separatedBy: "-")
        
        var month1 : String = ""
        
        switch dateArr[1] {
        case "01":
            month1 = "Jan"
        case "02":
            month1 = "Feb"
        case "03":
            month1 = "Mar"
        case "04":
            month1 = "Apr"
        case "05":
            month1 = "May"
        case "06":
            month1 = "Jun"
        case "07":
            month1 = "Jul"
        case "08":
            month1 = "Aug"
        case "09":
            month1 = "Sep"
        case "10":
            month1 = "Oct"
        case "11":
            month1 = "Nov"
        case "12":
            month1 = "Dec"
        default:
            month1 = "N/A"
            break
        }
        
        let newDate = month1 + " "  + dateArr[2] + ", " + dateArr[0]
        
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



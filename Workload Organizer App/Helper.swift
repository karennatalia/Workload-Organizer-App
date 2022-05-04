//
//  Helper.swift
//  Workload Organizer App
//
//  Created by Karen Natalia on 28/04/22.
//

import UIKit

class Helper {
    static func showAlert(title: String?, message: String?, over viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewController.present(alert, animated: true)
    }
    
    static func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: date)
    }
    
    static func getTimeString(hour: String, minute: String) -> String {
        var timeString = ""
        
        if hour != "" && hour != "0" {
            timeString += "\(hour) hour "
        }
        if minute != "" && minute != "0" {
            timeString += "\(minute) minutes "
        }
        
        return timeString
    }
}


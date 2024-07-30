//
//  Helper.swift
//  Calender
//
//  Created by mac on 22/01/1446 AH.
//

import Foundation
import UIKit
extension UIColor {
    
    static func hexStringToColor(hex: String) -> UIColor {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        
        if cString.count != 6 {
            return .systemGray
        }
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                       green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                       blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                       alpha: 1.0)
    }
    
}

extension UIApplication {
    
    var activeWindow: UIWindow? {
        UIApplication.shared.windows.first(where: { $0.isKeyWindow })
    }
    
    var statusBarHeight: CGFloat {
        activeWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 24
    }
    
    var windowSize: CGSize {
        windows.last?.bounds.size ?? UIScreen.main.bounds.size
    }
    
    var screenOffset: UIEdgeInsets {
        var oldInsets: UIEdgeInsets {
            let barHeight = UIApplication.shared.statusBarHeight
            return UIEdgeInsets(top: barHeight, left: 0, bottom: 0, right: 0)
        }
        return UIApplication.shared.activeWindow?.rootViewController?.view.safeAreaInsets ?? oldInsets
    }
    
}

struct Formatter {
    
    static func formatDate(dateString: String, inputFormat: String, outputFormat: String) -> String{
        let df = DateFormatter()
        df.locale = Locale(identifier: "en")
        df.dateFormat = inputFormat
        
        let date = df.date(from: dateString)
        df.dateFormat = outputFormat
        
        guard let date = date else { return ""}
        let time = df.string(from: date)
        return time
    }
}

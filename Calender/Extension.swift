//
//  Extension.swift
//  Calender
//
//  Created by mac on 22/01/1446 AH.
//

import Foundation
import UIKit

extension UIViewController {
    class func loadFromNib<T: UIViewController>() -> T {
        return T(nibName: String(describing: self), bundle: nil)
    }
}

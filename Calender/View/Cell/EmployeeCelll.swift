//
//  EmployeeCelll.swift
//  Calender
//
//  Created by mac on 24/01/1446 AH.
//

import UIKit

class EmployeeCelll: UICollectionViewCell {
    @IBOutlet weak var employeeName: UILabel!
    @IBOutlet weak var employeeImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        employeeImage.layer.cornerRadius = 25
        employeeImage.layer.masksToBounds = true
    }

    func setUpCell(employee: WorkingHoursData) {
        employeeName.text = employee.name ?? ""
    }
    
}

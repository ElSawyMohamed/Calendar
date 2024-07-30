//
//  AppointmentRequest.swift
//  Calender
//
//  Created by mac on 22/01/1446 AH.
//

import Foundation
struct AppointmentRequest: Codable {
    var dateFrom: String
    var dateTo: String
    var employeeIds: [Int]?
    var queryText: String?
    var appointmentStatuses: [String]?
    var place: String?

}

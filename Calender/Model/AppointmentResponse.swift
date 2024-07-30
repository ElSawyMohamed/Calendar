//
//  AppointmentResponse.swift
//  Calender
//
//  Created by mac on 22/01/1446 AH.
//

import Foundation

struct AppointmentResponse : Codable {
    let state : Int?
    let message : String?
    let data : [AppointmentResponseData]?
    let totalCount : Int?

    enum CodingKeys: String, CodingKey {

        case state = "state"
        case message = "message"
        case data = "data"
        case totalCount = "totalCount"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        state = try values.decodeIfPresent(Int.self, forKey: .state)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        data = try values.decodeIfPresent([AppointmentResponseData].self, forKey: .data)
        totalCount = try values.decodeIfPresent(Int.self, forKey: .totalCount)
    }

}


struct AppointmentResponseData : Codable {
    let totalItemInMinutes : Int?
    let status : Int?
    let clientName : String?
    let date : String?
    let transactionId : Int?
    let transactionItemId : Int?
    let employeeName : String?
    let employeeId : Int?
    let startTime : String?
    let endTime : String?

    enum CodingKeys: String, CodingKey {

        case totalItemInMinutes = "totalItemInMinutes"
        case status = "status"
        case clientName = "clientName"
        case date = "date"
        case transactionId = "transactionId"
        case transactionItemId = "transactionItemId"
        case employeeName = "employeeName"
        case employeeId = "employeeId"
        case startTime = "startTime"
        case endTime = "endTime"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        totalItemInMinutes = try values.decodeIfPresent(Int.self, forKey: .totalItemInMinutes)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
        clientName = try values.decodeIfPresent(String.self, forKey: .clientName)
        date = try values.decodeIfPresent(String.self, forKey: .date)
        transactionId = try values.decodeIfPresent(Int.self, forKey: .transactionId)
        transactionItemId = try values.decodeIfPresent(Int.self, forKey: .transactionItemId)
        employeeName = try values.decodeIfPresent(String.self, forKey: .employeeName)
        employeeId = try values.decodeIfPresent(Int.self, forKey: .employeeId)
        startTime = try values.decodeIfPresent(String.self, forKey: .startTime)
        endTime = try values.decodeIfPresent(String.self, forKey: .endTime)
    }

}

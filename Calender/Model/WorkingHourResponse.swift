//
//  WorkingHourResponse.swift
//  Calender
//
//  Created by mac on 22/01/1446 AH.
//

import Foundation
struct WorkingHourResponse : Codable {
    let state : Int?
    let message : String?
    let data : [WorkingHoursData]?
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
        data = try values.decodeIfPresent([WorkingHoursData].self, forKey: .data)
        totalCount = try values.decodeIfPresent(Int.self, forKey: .totalCount)
    }

}

struct WorkingHours : Codable {
    let weekDay : Int?
    let timeFrom : String?
    let timeFromInMS : Int?
    let timeTo : String?
    let timeToInMS : Int?
    let isDayOff : Bool?

    enum CodingKeys: String, CodingKey {

        case weekDay = "weekDay"
        case timeFrom = "timeFrom"
        case timeFromInMS = "timeFromInMS"
        case timeTo = "timeTo"
        case timeToInMS = "timeToInMS"
        case isDayOff = "isDayOff"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        weekDay = try values.decodeIfPresent(Int.self, forKey: .weekDay)
        timeFrom = try values.decodeIfPresent(String.self, forKey: .timeFrom)
        timeFromInMS = try values.decodeIfPresent(Int.self, forKey: .timeFromInMS)
        timeTo = try values.decodeIfPresent(String.self, forKey: .timeTo)
        timeToInMS = try values.decodeIfPresent(Int.self, forKey: .timeToInMS)
        isDayOff = try values.decodeIfPresent(Bool.self, forKey: .isDayOff)
    }

}

struct WorkingHoursData : Codable {
    let id : Int?
    let name : String?
    let image : String?
    let workingHours : [WorkingHours]?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case name = "name"
        case image = "image"
        case workingHours = "workingHours"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        image = try values.decodeIfPresent(String.self, forKey: .image)
        workingHours = try values.decodeIfPresent([WorkingHours].self, forKey: .workingHours)
    }

}

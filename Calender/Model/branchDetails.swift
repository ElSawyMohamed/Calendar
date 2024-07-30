//
//  branchDetails.swift
//  Calender
//
//  Created by mac on 22/01/1446 AH.
//

import Foundation
struct BranchDetails : Codable {
    let state : Int?
    let message : String?
    let data : [BranchDetailsData]?

    enum CodingKeys: String, CodingKey {

        case state = "state"
        case message = "message"
        case data = "data"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        state = try values.decodeIfPresent(Int.self, forKey: .state)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        data = try values.decodeIfPresent([BranchDetailsData].self, forKey: .data)
    }

}

struct BranchDetailsData : Codable {
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

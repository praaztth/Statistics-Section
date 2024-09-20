//
//  StatisticsModel.swift
//  Statistics Section
//
//  Created by tryuruy on 19.09.2024.
//

import Foundation
import RealmSwift

class StatisticsModel: Object {
    enum EventType: String {
        case visit = "view"
        case subscription = "subscription"
        case unsubscription = "unsubscription"
    }
    
    @Persisted var primary: String
    @Persisted var userId: Int
    @Persisted var type: EventType.RawValue
    @Persisted var listTimestamps = List<Double>()
    
    override class func primaryKey() -> String? {
        return "primary"
    }
    
    static func genPrimaty(userId: String, type: String) -> String {
        return [userId, type].joined(separator: "_")
    }
    
    func addTimestamp(timestamp: Double) {
        listTimestamps.append(timestamp)
    }
}

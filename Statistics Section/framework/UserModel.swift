//
//  UserModel.swift
//  Statistics Section
//
//  Created by tryuruy on 18.09.2024.
//

import Foundation
import RealmSwift

class UserModel: Object {
    @Persisted var id: Int
    @Persisted var sex: String
    @Persisted var username: String
    @Persisted var isOnline: Bool
    @Persisted var age: Int
    @Persisted var imageData: Data? = nil
    @Persisted var listVisitTimestamps = List<Double>()
    @Persisted var listSubscriptionsTimestamps = List<Double>()
    @Persisted var listUnsubscriptionsTimestamps = List<Double>()
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    func addVisitDate(date: Date) {
        let timestamp = date.timeIntervalSince1970
        listVisitTimestamps.append(timestamp)
    }
    
    func addSubscriptionDate(date: Date) {
        let timestamp = date.timeIntervalSince1970
        listSubscriptionsTimestamps.append(timestamp)
    }
    
    func addUnsubscriptionDate(date: Date) {
        let timestamp = date.timeIntervalSince1970
        listUnsubscriptionsTimestamps.append(timestamp)
    }
}

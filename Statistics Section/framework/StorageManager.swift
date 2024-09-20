//
//  StorageManager.swift
//  Statistics Section
//
//  Created by tryuruy on 19.09.2024.
//

import Foundation
import RealmSwift

class StorageManager {
    static let shared = StorageManager()
    
    func createUser(id: Int = Int.random(in: 0...100), sex: String, username: String, isOnline: Bool, age: Int, imageData: Data? = nil) {
        let userInstance = UserModel()
        userInstance.id = id
        userInstance.sex = sex
        userInstance.username = username
        userInstance.isOnline = isOnline
        userInstance.age = age
        userInstance.imageData = imageData
        
        do {
            let realm = try Realm()
            
            try realm.write {
                realm.add(userInstance)
            }
        } catch {
            print(error)
        }
    }
    
    func setImageData(id: Int, data: Data) {
        do {
            let realm = try Realm()
            if let userInstance = realm.object(ofType: UserModel.self, forPrimaryKey: id) {
                try realm.write {
                    userInstance.imageData = data
                }
            }
        } catch {
            print(error)
        }
    }
    
    func addVisitsDate(user id: Int, date: Date) {
        do {
            let realm = try Realm()
            if let userInstance = realm.object(ofType: UserModel.self, forPrimaryKey: id) {
                try realm.write {
                    userInstance.addVisitDate(date: date)
                }
            }
        } catch {
            print(error)
        }
    }
    
    func addSubscriptionsDate(user id: Int, date: Date) {
        do {
            let realm = try Realm()
            if let userInstance = realm.object(ofType: UserModel.self, forPrimaryKey: id) {
                try realm.write {
                    userInstance.addSubscriptionDate(date: date)
                }
            }
        } catch {
            print(error)
        }
    }
    
    func addUnsubscriptionsDate(user id: Int, date: Date) {
        do {
            let realm = try Realm()
            if let userInstance = realm.object(ofType: UserModel.self, forPrimaryKey: id) {
                try realm.write {
                    userInstance.addUnsubscriptionDate(date: date)
                }
            }
        } catch {
            print(error)
        }
    }
    
    func createStatisticsInstance(userId: Int, type: String, listDatesRaw: [Int]) {
        guard let type = StatisticsModel.EventType(rawValue: type) else { return }
        
        let listTimestamps = listDatesRaw.compactMap { dateInt in
            dateIntToTimestamp(date: dateInt)
        }
        
        do {
            let realm = try Realm()
            if let statisticsInstance = realm.object(ofType: StatisticsModel.self, forPrimaryKey: StatisticsModel.genPrimaty(userId: String(userId), type: type.rawValue)) {
                try listTimestamps.forEach { timestamp in
                    try realm.write {
                        statisticsInstance.addTimestamp(timestamp: timestamp)
                    }
                }
                
                return
            }
        } catch {
            print(error)
        }
        
        let statisticsInstance = StatisticsModel()
        statisticsInstance.userId = userId
        statisticsInstance.type = type.rawValue
        statisticsInstance.primary = StatisticsModel.genPrimaty(userId: String(userId), type: type.rawValue)
        
        statisticsInstance.listTimestamps.append(objectsIn: listTimestamps)
        
        do {
            let realm = try Realm()
            
            try realm.write {
                realm.add(statisticsInstance)
            }
        } catch {
            print(error)
        }
    }
    
    func dateIntToTimestamp(date: Int) -> Double? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMyyyy"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.isLenient = true
        
        let timestamp = dateFormatter.date(from: String(date))?.timeIntervalSince1970
        return timestamp
    }
}

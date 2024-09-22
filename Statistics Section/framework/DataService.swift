//
//  DataService.swift
//  Statistics Section
//
//  Created by tryuruy on 21.09.2024.
//

import Foundation
import RealmSwift

struct UsersResponce: Decodable {
    var users: [UserJson]
}

struct UserJson: Decodable {
    var id: Int
    var sex: String
    var username: String
    var isOnline: Bool
    var age: Int
    var files: [File]
}

struct File: Decodable {
    var id: Int
    var url: String
    var type: String
}

struct StatisticsResponce: Decodable {
    var statistics: [StatisticJson]
}
        
struct StatisticJson: Decodable {
    var user_id: Int
    var type: String
    var dates: [Int]
}

class DataService {
    static let usersUrl = "https://cars.cprogroup.ru/api/episode/users/"
    static let statisticsUrl = "https://cars.cprogroup.ru/api/episode/statistics/"
    
    static let shared = DataService()
    
    func loadData(completionHandler: @escaping ([StatisticsViewController.User], [StatisticsModel]) -> Void) {
        do {
            let realm = try Realm()
            let usersInstance = realm.objects(UserModel.self)
            let statisticsInstance = realm.objects(StatisticsModel.self)
            
            // If there is no data in the database then the method loads it from the server
            if usersInstance.isEmpty && statisticsInstance.isEmpty {
                fetchDataFromServer { users, statistics in
                    users.forEach { user in
                        StorageManager.shared.createUser(id: user.id, sex: user.sex, username: user.username, isOnline: user.isOnline, age: user.age)
                        
                        if let imageUrl = user.files.first(where: { $0.type == "avatar" })?.url {
                            NetworkManager.shared.fetchImage(from: imageUrl) { data in
                                StorageManager.shared.setImageData(id: user.id, data: data)
                            }
                        }
                    }
                    
                    statistics.forEach { statisticsElement in
                        StorageManager.shared.createStatisticsInstance(userId: statisticsElement.user_id, type: statisticsElement.type, listDatesRaw: statisticsElement.dates)
                    }
                    
                    self.loadData(completionHandler: completionHandler)
                }
            }
        } catch {
            print(error)
        }
    }
    
    func fetchDataFromServer(completionHandler: @escaping ([UserJson], [StatisticJson]) -> Void) {
        NetworkManager.shared.fetchData(from: DataService.usersUrl, type: UsersResponce.self) { usersObject in
            NetworkManager.shared.fetchData(from: DataService.statisticsUrl, type: StatisticsResponce.self) { statisticsObject in
                completionHandler(usersObject.users, statisticsObject.statistics)
            }
        }
    }
    
    func prepareUsers(users: [UserModel]) -> [StatisticsViewController.User] {
        let preparedUsers = users.prefix(3).map { object in
            StatisticsViewController.User(name: object.username, age: object.age, isOnline: object.isOnline, avatarData: object.imageData)
        }
        
        return preparedUsers
    }
}

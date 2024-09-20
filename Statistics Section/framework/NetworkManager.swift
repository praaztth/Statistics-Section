//
//  NetworkManager.swift
//  Statistics Section
//
//  Created by tryuruy on 18.09.2024.
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
    var statistics: [Statistic]
}
        
struct Statistic: Decodable {
    var user_id: Int
    var type: String
    var dates: [Int]
}

class NetworkManager {
    static let usersUrl = "https://cars.cprogroup.ru/api/episode/users/"
    static let statisticsUrl = "https://cars.cprogroup.ru/api/episode/statistics/"
    
    static let shared = NetworkManager()
    
    func fetchUsers(completion: @escaping ([UserJson]) -> Void) {
        guard let url = URL(string: NetworkManager.usersUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { data, responce, error in
            guard let data = data, error == nil else { return }
            
            do {
                let responce: UsersResponce = try JSONDecoder().decode(UsersResponce.self, from: data)
                
                completion(responce.users)
            } catch {
                print(error)
            }
        }.resume()
    }
    
    func fetchAvatarForUser(id: Int, url: String, completion: @escaping (Data) -> Void) {
        guard let url = URL(string: url) else { return }
        
        URLSession.shared.dataTask(with: url) { data, responce, error in
            guard let data = data, error == nil else { return }
            
            completion(data)
        }.resume()
        
    }
    
    func fetchStatistics(completion: @escaping ([Statistic]) -> Void) {
        guard let url = URL(string: NetworkManager.statisticsUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { data, responce, error in
            guard let data = data, error == nil else { return }
            
            do {
                let responce: StatisticsResponce = try JSONDecoder().decode(StatisticsResponce.self, from: data)
                
                completion(responce.statistics)
            } catch {
                print(error)
            }
        }.resume()
    }
}

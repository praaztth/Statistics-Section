//
//  NetworkManager.swift
//  Statistics Section
//
//  Created by tryuruy on 18.09.2024.
//

import Foundation
import RealmSwift

struct Responce: Decodable {
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

class NetworkManager {
    static let usersUrl = "https://cars.cprogroup.ru/api/episode/users/"
    
    static let shared = NetworkManager()
    
    func fetchUsers(completion: @escaping ([UserJson]) -> Void) {
        guard let url = URL(string: NetworkManager.usersUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { data, responce, error in
            guard let data = data, error == nil else { return }
            
            do {
                let responce: Responce = try JSONDecoder().decode(Responce.self, from: data)
                
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
}

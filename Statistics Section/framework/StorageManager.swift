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
}

//
//  UserModel.swift
//  Statistics Section
//
//  Created by tryuruy on 18.09.2024.
//

import Foundation
import RealmSwift

class UserModel: Object, Decodable {
    @Persisted var id: Int
    @Persisted var sex: String
    @Persisted var username: String
    @Persisted var isOnline: Bool
    @Persisted var age: Int
    @Persisted var imageData: Data? = nil
    @Persisted var numberOfVisits: Int = 0
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

//
//  NetworkManager.swift
//  Statistics Section
//
//  Created by tryuruy on 18.09.2024.
//

import Foundation
import RealmSwift

class NetworkManager {
    static let shared = NetworkManager()
    
    func fetchData<T: Decodable>(from url: String, type: T.Type, completion: @escaping (T) -> Void) {
        guard let url = URL(string: url) else { return }
        
        URLSession.shared.dataTask(with: url) { data, responce, error in
            guard let data = data, error == nil else { return }
            
            do {
                let responce: T = try JSONDecoder().decode(T.self, from: data)
                
                completion(responce)
            } catch {
                print(error)
            }
        }.resume()
    }
    
    func fetchImage(from url: String, completion: @escaping (Data) -> Void) {
        guard let url = URL(string: url) else { return }
        
        URLSession.shared.dataTask(with: url) { data, responce, error in
            guard let data = data, error == nil else { return }
            
            completion(data)
        }.resume()
        
    }
}

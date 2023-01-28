//
//  DatabaseManager.swift
//  BeltExam_GroceryList
//
//  Created by Nuha Alharbi on 08/01/2023.
//

import Foundation
import FirebaseDatabase

enum DatabaseError: Error {
    case failedToFetch
}

final class DatabaseManger {
    
    // MARK: - Vars
    
    static let shared = DatabaseManger()
    private let groceryItemsRef = Database.database().reference(withPath: "grocery-items")
    private let onlineUsersRef = Database.database().reference(withPath: "online")
    
    // MARK: - Grocery list Opreations
    
    public func retrieveGroceryitems(completion: @escaping (Result<[GroceryItem]?, Error>) -> Void) {
        groceryItemsRef.observe(.value) { snapshot  in
            guard let value = snapshot.value as? [String : [String : Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let groceryItems : [GroceryItem] = value.compactMap { (key, value) in
                guard let name = value["name"] as? String,
                      let addedBy = value["addedBy"] as? String,
                      let completed = value["completed"] as? Bool,
                      let priority = value["priority"] as? Int else {
                    return nil
                }
                
                return GroceryItem(name: name, addedBy: addedBy, completed: completed, priority: priority)
            }
            
            completion(.success(groceryItems))
        }
    }
    
    public func insertNewGroceryitem(with item : GroceryItem){
        groceryItemsRef.child(item.name.lowercased()).setValue(item.toDictionary()){ error, _ in
            guard error == nil else {
                print("Failed to insert item")
                return
            }
        }
    }
    
    public func deleteGroceryitem(for itemName : String){
        groceryItemsRef.child(itemName.lowercased()).removeValue { error, _ in
            guard error == nil else {
                print("Failed to remove item")
                return
            }
        }
    }
    
    public func updateGroceryItem(for itemName : String, with newItem: GroceryItem){
        groceryItemsRef.observeSingleEvent(of: .value) { snapshot in
            guard var groceryItems = snapshot.value as? [String : [String : Any]] else {
                return
            }
            groceryItems.removeValue(forKey: itemName.lowercased())
            groceryItems[newItem.name.lowercased()] = newItem.toDictionary()
            
            self.groceryItemsRef.setValue(groceryItems) { error, _ in
                guard error == nil else {
                    print("Failed to update item")
                    return
                }
            }
        }
    }
    
    public func updatdCompletedStatus(for itemName : String, with checkmarkStatus: Bool) {
        groceryItemsRef.child(itemName.lowercased()).updateChildValues([
            "completed": checkmarkStatus
        ]) { error, _ in
            guard error == nil else {
                print("Failed to update completed status")
                return
            }
        }
    }
    
    // MARK: - Online Users Opreations
    
    public func retrieveOnlineUsers(completion: @escaping (Result<[String], Error>) -> Void) {
        onlineUsersRef.observe(.value) { snapshot  in
            guard let value = snapshot.value as? [String : String] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let onlineUsers : [String] = value.compactMap { (key, value) in
                return value
            }
            
            completion(.success(onlineUsers))
        }
    }
    
    public func insertOnlineUser(userId : String, userEmail : String) {
        let userRef = onlineUsersRef.child(userId)
        userRef.setValue(userEmail) { error, _ in
            guard error == nil else {
                print("Failed to insert online user")
                return
            }
        }
        
        userRef.onDisconnectRemoveValue()
    }
    
    public func removeOnlineUser(userId : String) {
        onlineUsersRef.child(userId).removeValue() { error, _ in
            guard error == nil else {
                print("Failed to remove online user")
                return
            }
        }
    }
}






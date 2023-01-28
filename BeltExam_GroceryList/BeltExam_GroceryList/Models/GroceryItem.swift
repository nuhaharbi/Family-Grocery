//
//  groceryItem.swift
//  BeltExam_GroceryList
//
//  Created by Nuha Alharbi on 08/01/2023.
//

import Foundation

struct GroceryItem {
    var name : String
    let addedBy : String
    var completed : Bool
    var priority : Int
    
    func toDictionary() -> [String : Any] {
        let dectionary = ["name" : name, "completed" : completed, "addedBy" : addedBy, "priority" : priority] as [String : Any]
        return dectionary
    }
}

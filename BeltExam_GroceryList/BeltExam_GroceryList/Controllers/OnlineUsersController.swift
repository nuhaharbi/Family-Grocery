//
//  OnlineUsersController.swift
//  BeltExam_GroceryList
//
//  Created by Nuha Alharbi on 08/01/2023.
//

import UIKit

class OnlineUsersController: UITableViewController {
    
    //MARK: - Vars
    
    var onlineUsers = [String]()
    
    //MARK: - App lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Online Users"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DatabaseManger.shared.retrieveOnlineUsers { result in
            if let result = try? result.get() {
                self.onlineUsers = result
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        onlineUsers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "onlineUserCell", for: indexPath)
        cell.textLabel?.text = onlineUsers[indexPath.row]
        
        return cell
    }
}

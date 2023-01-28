//
//  GroceryListController.swift
//  BeltExam_GroceryList
//
//  Created by Nuha Alharbi on 08/01/2023.
//

import UIKit

class GroceryListController: UITableViewController {
    
    // MARK: - Vars
    
    var groceryItems = [GroceryItem]()
    let priorites = ["🔴 High","🟠 Medium","🔵 Low"]
    let priorityPickerView = UIPickerView()
    let toolbar = UIToolbar(frame:CGRect(x:0, y:0, width:50, height:50))
    var textFieldPicker = UITextField()
    
    // MARK: - App lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationItems()
        setUpFloatingButton()
        priorityPickerView.dataSource = self
        priorityPickerView.delegate = self
        tableView.register(UINib(nibName: "GroceryItemCell", bundle: nil), forCellReuseIdentifier: "GroceryItemCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AuthenticationManager.shared.listenToUserState { user in
            self.dismiss(animated: true)
            if let user = user,
               let userEmail = user.email {
                
                DatabaseManger.shared.insertOnlineUser(userId: user.uid, userEmail: userEmail)
                DatabaseManger.shared.retrieveGroceryitems { result in
                    guard let result = try? result.get() else {return}
                    
                    // Sort items based on their priority then sort them based on weather they were checked or not
                    self.groceryItems = result.sorted(by: {($0.priority < $1.priority)}).sorted(by: {(!$0.completed && $1.completed) })
                    self.tableView.reloadData()
                }
            } else {
                guard let LoginVC = self.storyboard?.instantiateViewController(withIdentifier: "navTologin") else {return}
                LoginVC.modalPresentationStyle = .fullScreen
                self.present(LoginVC, animated: true)
            }
        }  
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        groceryItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroceryItemCell", for: indexPath) as? GroceryItemCell else {
            return UITableViewCell()
        }
        
        cell.itemName.text = groceryItems[indexPath.row].name
        cell.userEmail.text = groceryItems[indexPath.row].addedBy
        cell.priorityEmoji.text = String(priorites[groceryItems[indexPath.row].priority - 1].split(separator: " ")[0])
        
        // Change cell appearnce based on the completed status
        cell.itemName.attributedText = groceryItems[indexPath.row].completed ? cell.itemName.text?.strikeThrough() : cell.itemName.text?.removeStrikeThrough()
        cell.checkmarkView.isHidden = !groceryItems[indexPath.row].completed
        cell.accessoryType = groceryItems[indexPath.row].completed ? .checkmark : .none
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) else {return}
        
        if cell.accessoryType == .checkmark {
            groceryItems[indexPath.row].completed = false
            cell.accessoryType = .none
        } else {
            groceryItems[indexPath.row].completed = true
            cell.accessoryType = .checkmark
        }
        
        DatabaseManger.shared.updatdCompletedStatus(for: groceryItems[indexPath.row].name,
                                                    with: groceryItems[indexPath.row].completed)
        
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
            DatabaseManger.shared.deleteGroceryitem(for: self.groceryItems[indexPath.row].name)
            self.groceryItems.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, handler) in
            self.displayAlert(forAddingItem : false, indexPath)
        }
        
        editAction.backgroundColor = .systemBlue
        deleteAction.backgroundColor = .red
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
    
    // MARK: - @objc Functions
    
    @objc func addItem(){
        displayAlert(forAddingItem : true, nil)
    }
    
    @objc func navigateToOnlineUsers(){
        guard let onlineUsersVC = storyboard?.instantiateViewController(withIdentifier: "onlineUsers") as? OnlineUsersController else {return}
        navigationController?.pushViewController(onlineUsersVC, animated: true)
    }
    
    @objc func dismissPickerPressed(){
        textFieldPicker.endEditing(true)
    }
    
    @objc func logOut(){
        guard let userId = AuthenticationManager.shared.getCurrentUser()?.uid else {return}
        DatabaseManger.shared.removeOnlineUser(userId: userId )
        AuthenticationManager.shared.logOutUser(){ error in
            if let errorMessage = error {
                self.displayErrorAlert(message: errorMessage)
            }
        }
    }
    
    // MARK: - Functions
    
    func setUpNavigationItems() {
        
        // To show the current number of online users
        DatabaseManger.shared.retrieveOnlineUsers { result in
            if let result = try? result.get() {
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "\(result.count)",
                                                                        style: .plain,
                                                                        target: self,
                                                                        action: #selector(self.navigateToOnlineUsers))
            }
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(image : UIImage(systemName: "rectangle.portrait.and.arrow.forward"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(logOut))
    }
    
    func setUpFloatingButton() {
        let floatingButton = UIButton()
        floatingButton.setTitle("+", for: .normal)
        floatingButton.backgroundColor = .black
        floatingButton.shadowOffset = .init(width: 2, height: 3)
        floatingButton.shadowOpacity = 0.5
        floatingButton.layer.cornerRadius = 25
        floatingButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        floatingButton.addTarget(self, action: #selector(addItem), for: .touchUpInside)
        
        view.addSubview(floatingButton)
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        
        floatingButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        floatingButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        floatingButton.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor, constant: -10).isActive = true
        floatingButton.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor, constant: -10).isActive = true
    }
    
    // Use this alert for both adding and editing items based on the boolean value "forAddingItem"
    func displayAlert(forAddingItem : Bool, _ indexPath: IndexPath?){
        let alertController = UIAlertController(title: forAddingItem ? "Add new item" : "Edit item", message: nil , preferredStyle: .alert)
        
        /// Alert Actions
        let confirmAction = UIAlertAction(title: forAddingItem ? "Add" : "Save" , style: .default) { (_) in
            if let itemField = alertController.textFields?[0],
               let item = itemField.text,
               let prioityField = alertController.textFields?[1],
               let priority = prioityField.text {
                
                let priorityNum = (self.priorites.firstIndex(of: priority) ?? 2 ) + 1
                
                if forAddingItem {
                    guard let userEmil = AuthenticationManager.shared.getCurrentUser()?.email else {return}
                    let newItem = GroceryItem(name: item,
                                              addedBy: userEmil,
                                              completed: false,
                                              priority: priorityNum)
                    DatabaseManger.shared.insertNewGroceryitem(with: newItem)
                } else {
                    guard let indexPath = indexPath else {return}
                    var editedItem = self.groceryItems[indexPath.row]
                    editedItem.name = item
                    editedItem.priority = priorityNum
                    DatabaseManger.shared.updateGroceryItem(for: self.groceryItems[indexPath.row].name,
                                                            with: editedItem)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        /// Alert Textfields
        alertController.addTextField { (textField) in
            if forAddingItem {
                textField.placeholder = "item"
            } else {
                guard let indexPath = indexPath else {return}
                textField.text = self.groceryItems[indexPath.row].name
            }
        }
        
        alertController.addTextField { (textField) in
            if forAddingItem {
                textField.placeholder = "Piriorty"
            } else {
                guard let indexPath = indexPath else {return}
                textField.text = self.priorites[self.groceryItems[indexPath.row].priority - 1]
            }
            
            // When the textfield pressed a toolbar with pickerview will show up to allow the user to choose a value of the priority
            self.toolbar.barStyle = UIBarStyle.default
            let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.dismissPickerPressed))
            let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
            self.toolbar.setItems([spaceButton, doneButton], animated: true)
            self.toolbar.sizeToFit()
            self.toolbar.tintColor = UIColor(red: 235/255, green: 28/255, blue: 85/255, alpha: 1)

            textField.inputAccessoryView = self.toolbar
            textField.inputView = self.priorityPickerView
            
            self.textFieldPicker = textField
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        alertController.view.tintColor = UIColor(red: 235/255, green: 28/255, blue: 85/255, alpha: 1)
        
        self.present(alertController, animated: true)
    }
    
    func displayErrorAlert(message: String){
        let alertController = UIAlertController(title:"Error", message: message , preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        alertController.view.tintColor = UIColor(red: 235/255, green: 28/255, blue: 85/255, alpha: 1)
        
        present(alertController, animated: true, completion: nil)
    }
    
}

// MARK: - Extension

extension GroceryListController : UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        priorites.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        priorites[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.textFieldPicker.text = priorites[row]
    }
}



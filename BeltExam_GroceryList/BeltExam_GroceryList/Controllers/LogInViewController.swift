//
//  LogInViewController.swift
//  BeltExam_GroceryList
//
//  Created by Nuha Alharbi on 09/01/2023.
//

import UIKit

class LogInViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - Actions
    
    @IBAction func logInPressed(_ sender: Any) {
        if let userEmail = emailTextField.text,
           let userPassword = passwordTextField.text {
            AuthenticationManager.shared.logInUser(email: userEmail, password: userPassword) { error in
                if let errorMessage = error {
                    self.displayErrorAlert(message: errorMessage)
                }
            }
        }
    }
    
    @IBAction func registerPressed(_ sender: Any) {
        if let registerVC = storyboard?.instantiateViewController(withIdentifier: "register") as? RegisterViewController {
            navigationController?.pushViewController(registerVC, animated: true)
        }
    }
    
    @IBAction func facebookLoginPressed(_ sender: Any) {
        AuthenticationManager.shared.facebookLogIn(targetVC: self) { error in
            if let errorMessage = error {
                self.displayErrorAlert(message: errorMessage)
            }
        }
    }
    
    // MARK: - Functions
    
    func displayErrorAlert(message: String){
        let alertController = UIAlertController(title:"Error", message: message , preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        alertController.view.tintColor = UIColor(red: 235/255, green: 28/255, blue: 85/255, alpha: 1)
        
        present(alertController, animated: true, completion: nil)
    }
}

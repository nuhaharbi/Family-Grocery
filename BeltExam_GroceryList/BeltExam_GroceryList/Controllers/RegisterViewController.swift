//
//  RegisterViewController.swift
//  BeltExam_GroceryList
//
//  Created by Nuha Alharbi on 09/01/2023.
//

import UIKit

class RegisterViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    
    // MARK: - Vars
    
    var emailAddressFilled : Bool = false
    var passwordFilled : Bool = false
    var confirmPasswordFilled : Bool = false
    
    // MARK: - App lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Register"
    }
    
    // MARK: - Actions
    
    @IBAction func emailChanged(_ sender: Any) {
        if let email = emailTextField.text {
            
            if let message = invalidEmail(email) {
                errorMessage.text = message
                emailAddressFilled = false
            } else {
                errorMessage.text = ""
                emailAddressFilled = true
            }
        }
        
        checkForValidForm()
    }
    
    @IBAction func passwordChanged(_ sender: Any) {
        if let password = passwordTextField.text {
            
            if password.count < 8 {
                errorMessage.text = "Password must be at least 8 characters long"
                passwordFilled = false
            } else {
                errorMessage.text = ""
                passwordFilled = true
            }
        }
        
        checkForValidForm()
    }
    
    @IBAction func confirmPasswordChange(_ sender: Any) {
        if let confirmPassword = confirmPassword.text,
           let password = passwordTextField.text {
            
            if confirmPassword != password {
                errorMessage.text = "Passwords does not match"
                confirmPasswordFilled = false
            } else {
                errorMessage.text = ""
                confirmPasswordFilled = true
            }
        }
        
        checkForValidForm()
    }
    
    @IBAction func registerPressed(_ sender: Any) {
        if let userEmail = emailTextField.text,
           let userPassword = passwordTextField.text {
            AuthenticationManager.shared.registerUser(email: userEmail, password: userPassword){ error in
                if let errorMessage = error {
                    self.displayErrorAlert(message: errorMessage)
                }
            }
        }
    }
    
    // MARK: - Functions
    
    func invalidEmail(_ value: String) -> String? {
        let reqularExpression = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", reqularExpression)
        if !predicate.evaluate(with: value)
        {
            return "Invalid Email Address"
        }
        
        return nil
    }
    
    func checkForValidForm() {
        if emailAddressFilled && passwordFilled && confirmPasswordFilled {
            registerButton.isEnabled = true
        } else {
            registerButton.isEnabled = false
        }
    }
    
    func displayErrorAlert(message: String){
        let alertController = UIAlertController(title:"Error", message: message , preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        alertController.view.tintColor = UIColor(red: 235/255, green: 28/255, blue: 85/255, alpha: 1)
        
        present(alertController, animated: true, completion: nil)
    }
}

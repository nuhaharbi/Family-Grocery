//
//  AuthenticationManager.swift
//  BeltExam_GroceryList
//
//  Created by Nuha Alharbi on 09/01/2023.
//

import UIKit
import FirebaseAuth
import FacebookLogin

final class AuthenticationManager {
    
    // MARK: - Vars
    var handle : AuthStateDidChangeListenerHandle?
    static let shared = AuthenticationManager()
    private let firebaseAuth = Auth.auth()
    
    // MARK: - Authentication Functons
    
    public func logInUser(email : String, password : String, completion: @escaping ((String?) -> Void)) {
        firebaseAuth.signIn(withEmail: email, password: password, completion: { authResult, error in
            guard error == nil else {
                completion(error?.localizedDescription)
                return
            }
            completion(nil)
        })
    }
    
    public func registerUser(email : String, password : String, completion: @escaping ((String?) -> Void)) {
        firebaseAuth.createUser(withEmail: email, password: password, completion: { authResult , error  in
            guard error == nil else {
                completion(error?.localizedDescription)
                return
            }
            completion(nil)
        })
    }
    
    public func logOutUser(completion: @escaping ((String?) -> Void)) {
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            completion(signOutError.localizedDescription)
        }
    }
    
    public func facebookLogIn(targetVC : UIViewController, completion: @escaping ((String?) -> Void)){
        let fbLoginManager : LoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["public_profile","email"], from: targetVC) { (result, error) -> Void in
            guard error == nil,
                  result?.isCancelled == false,
                  let currentAccessToken = AccessToken.current?.tokenString
            else { return }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: currentAccessToken )
            
            self.firebaseAuth.signIn(with: credential) { (authResult, error) in
                if let error = error {
                    completion(error.localizedDescription)
                }
            }
        }
    }
    
    public func listenToUserState(completion: @escaping ((User?) -> Void)) {
        if handle != nil {return}
        handle = firebaseAuth.addStateDidChangeListener { auth, user in
            completion(user)
        }
    }
    
    public func getCurrentUser() -> User? {
        guard let currentUser = firebaseAuth.currentUser else { return nil }
        return currentUser
    }
}


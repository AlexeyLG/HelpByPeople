//
//  AuthHelper.swift
//  HelpBYpeople
//
//  Created by Alexey on 12/7/20.
//

import UIKit
import Firebase

class AuthHelper {
    
    static let shared = AuthHelper()
    
    private let authKey = "auth_key"
    
    var isLoggedIn: Bool {
        get {
            UserDefaults.standard.bool(forKey: authKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: authKey)
        }
    }
    
    private init() {}
    
    func logOut() {
        isLoggedIn = false
        
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error can't signOut!")
        }
        
        setupRootViewController(with: "AuthViewController")
    }
    
    func login() {
        isLoggedIn = true
        setupRootViewController(with: "TabBarViewController")
    }
    
    private func setupRootViewController(with identifier: String) {
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let sceneDelegate = windowScene.delegate as? SceneDelegate
        else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: identifier)
        
        sceneDelegate.window?.rootViewController = viewController
    }
}

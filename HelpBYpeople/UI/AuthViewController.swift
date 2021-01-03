//
//  AuthViewController.swift
//  HelpBYpeople
//
//  Created by Alexey on 11/22/20.
//

import UIKit
import Firebase

class AuthViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var memberLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
        
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        welcomeLabel.text = L10n("Welcome")
        emailTextField.placeholder = L10n("Email")
        passwordTextField.placeholder = L10n("Password")
        loginButton.setTitle(L10n("Login"), for: .normal)
        loginButton.roundCorners()
        memberLabel.text = L10n("member")
        registerButton.setTitle(L10n("Register"), for: .normal)
        
        //UITapGestureRecognizer
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AuthViewController.dismissKeyboard))
            view.addGestureRecognizer(tap)
    }
    
    // MARK: - Actions
    
    @IBAction func loginButtonDidTap(_ sender: Any) {
        
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              !email.isEmpty, !password.isEmpty
        else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            guard let self = self else { return }
            
            if result != nil {
                AuthHelper.shared.login()
            } else if let error = error {
                self.showError(error.localizedDescription)
            }
        }
    }
    
    @IBAction func registerButtonDidTap(_ sender: Any) {
        self.performSegue(withIdentifier: "registerSegue", sender: nil)
    }
    
    // MARK: - Private
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
       }
    
}

    // MARK: - UITextFieldDelegate

extension AuthViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            self.view.endEditing(true)
        }
        
        return true
    }
}

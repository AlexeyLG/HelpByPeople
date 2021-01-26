//
//  RegisterViewController.swift
//  HelpBYpeople
//
//  Created by Alexey on 11/23/20.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var createUserIndicator: UIActivityIndicatorView!
    @IBOutlet weak var topSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var validationUserName: UILabel!
    @IBOutlet weak var validationEmail: UILabel!
    @IBOutlet weak var validationPassword: UILabel!
    @IBOutlet weak var userNameTitleLabel: UILabel!
    @IBOutlet weak var userEmailTitleLabel: UILabel!
    @IBOutlet weak var userPasswordTitleLabel: UILabel!
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        userEmailTextField.delegate = self
        userPasswordTextField.delegate = self
        userNameTextField.delegate = self
        
        navigationItem.title = L10n("New User")
        addPhotoButton.setTitle(L10n("Add Photo"), for: .normal)
        userEmailTextField.placeholder = L10n("add.email")
        userPasswordTextField.placeholder = L10n("add.password")
        userNameTextField.placeholder = L10n("add.user.name")
        userNameTitleLabel.text = L10n("user.name")
        userPasswordTitleLabel.text = L10n("user.password")
        userEmailTitleLabel.text = L10n("user.email")
        
        subscribeForKeyboardnotifications()
        createUserIndicator.isHidden = true
        
        //Validation
        userNameTextField.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        userEmailTextField.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        userPasswordTextField.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        
        //UITapGestureRecognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            view.addGestureRecognizer(tap)
  
        let tapGestureRecodnizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        photoImageView.isUserInteractionEnabled = true
        photoImageView.addGestureRecognizer(tapGestureRecodnizer)
    }
    
    // MARK: - Actions
    
    @IBAction func cancelButtonDidTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonDidTap(_ sender: Any) {
        createNewUser()
    }
    
    @IBAction func addPhotoButtonDidTap(_ sender: Any) {
        presentPhotoActionMenu()
    }
    
    // MARK: - Private
    
    private func createNewUser() {
       
        guard let email = userEmailTextField.text,
              let password = userPasswordTextField.text,
              let userName = userNameTextField.text,
              let image = photoImageView.image ?? UIImage(named: "defaultPhoto.jpg"),
              !email.isEmpty, !password.isEmpty, !userName.isEmpty
        else { return }
 
        
        createUserIndicator.isHidden = false
        createUserIndicator.startAnimating()
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            guard let self = self else { return }
            
            self.uploadProfileImage(image) { url in
                guard let url = url else { return }
                
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = userName
                changeRequest?.photoURL = url
                
                changeRequest?.commitChanges { error in
                    if error == nil {
                        print("User display name changed!")
                        self.saveProfile(userName: userName, userEmail: email, userPassword: password, profileImageURL: url) { success in
                            if success {
                                self.createUserIndicator.stopAnimating()
                                self.createUserIndicator.isHidden = true
                                AuthHelper.shared.login()
                            }
                        }
                    } else {
                        print("User display name did not changed!")
                    }
                }
            }
        }
    }
        
    private func uploadProfileImage(_ image: UIImage, completion: @escaping ((_ url: URL?) -> Void)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        storageRef("user/\(uid)").putData(imageData, metadata: metaData) { (metaData, error) in
            if error == nil, metaData != nil {
                storageRef("user/\(uid)").downloadURL { (url, error) in
                    completion(url)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    private func saveProfile(userName: String, userEmail: String, userPassword: String, profileImageURL: URL, completion: @escaping ((_ success: Bool) -> Void)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let databaseRef = Database.database().reference().child("users/profile/\(uid)")
        
        let userObject = [
            "userName" : userName,
            "userEmail" : userEmail,
            "userPassword" : userPassword,
            "photoUrl" : profileImageURL.absoluteString
        ] as [String : Any]
        
        databaseRef.setValue(userObject) { (error, ref) in
            completion(error == nil)
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func presentPhotoActionMenu() {
        presentPhotoActionMenuViewController() { [weak self] image in
            self?.photoImageView.image = image
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        presentPhotoActionMenu()
    }
    
    @objc fileprivate func handleTextChange() {
        guard let userName = userNameTextField.text,
              let email = userEmailTextField.text,
              let password = userPasswordTextField.text
        else { return }
        
        if userName.isValid(String.ValidityType.name) {
            validationUserName.text = L10n("valid.user.name")
        } else {
            validationUserName.isHidden = false
            validationUserName.text = L10n("not.valid.user.name")
        }
        
        if email.isValid(String.ValidityType.email) {
            validationEmail.text = L10n("valid.user.email")
        } else {
            validationEmail.isHidden = false
            validationEmail.text = L10n("not.valid.user.email")
        }
        
        if password.isValid(String.ValidityType.name) {
            validationPassword.text = L10n("valid.user.password")
        } else {
            validationPassword.isHidden = false
            validationPassword.text = L10n("not.valid.user.password")
        }
    }
    
    // MARK: - Keyboard Utils
   
    private func subscribeForKeyboardnotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didRecieveKeyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didRecieveKeyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
   
    @objc private func didRecieveKeyboardWillShow(notification: Notification) {
        print("will show keyboard")
        adjustContentPosition(show: true, notfication: notification)
    }
    
    @objc private func didRecieveKeyboardWillHide(notification: Notification) {
        print("will hide keyboard")
        adjustContentPosition(show: false, notfication: notification)
    }
    
    private func adjustContentPosition(show: Bool, notfication: Notification) {
        guard
            let userInfo = notfication.userInfo,
            let leyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else { return }
        
        let additionalHeight = show ? (leyboardFrame.cgRectValue.height - 60) : 306
        
        UIView.animate(withDuration: 0.3) { [unowned self] in
            self.topSpaceConstraint.constant = additionalHeight
            self.view.layoutIfNeeded()
        }
    }
 
}

    // MARK: - UITextFieldDelegate

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == userNameTextField {
            userEmailTextField.becomeFirstResponder()
        } else if textField == userEmailTextField {
            userPasswordTextField.becomeFirstResponder()
        } else if textField == userPasswordTextField {
            self.view.endEditing(true)
        }
        return true
    }
    
}

    // MARK: - UIImagePickerControllerDelegate

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            photoImageView.image = image
        } else {
            photoImageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIImageView

extension UIImageView {
    func setRounded() {
        self.layer.cornerRadius = (self.frame.width / 2)
        self.layer.masksToBounds = true
    }
}



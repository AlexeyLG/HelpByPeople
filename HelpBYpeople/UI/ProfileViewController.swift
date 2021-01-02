//
//  ProfileViewController.swift
//  HelpBYpeople
//
//  Created by Alexey on 11/23/20.
//

import UIKit
import Firebase
import Kingfisher

class ProfileViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var emailButtonLabel: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
      profileConfig()
        tabBarItem.title = L10n("Profile")
        emailButtonLabel.text = L10n("mail")
        logOutButton.setTitle(L10n("logout"), for: .normal)
    }
    
    // MARK: - Actions
    
    @IBAction func emailButtonDidTap(_ sender: Any) {
        print("Send e-mail")
    }
    
    @IBAction func logOutButtonDidTap(_ sender: Any) {        
        AuthHelper.shared.logOut()
    }
        
    // MARK: - Private
    
    private func profileConfig() {
        guard let user = Auth.auth().currentUser else { return }
        
        userNameLabel.text = user.displayName
        emailLabel.text = user.email
        photoImageView.kf.setImage(with: user.photoURL)
        photoImageView.setRounded()
    }
    
}

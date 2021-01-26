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
    @IBOutlet weak var userNameTitleLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userEmailTitleLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tabBarItem.title = L10n("Profile")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileConfig()
        logOutButton.setTitle(L10n("logout"), for: .normal)
        userNameTitleLabel.text = L10n("user.name")
        userEmailTitleLabel.text = L10n("user.email")
        logOutButton.roundCorners()
    }
    
    // MARK: - Actions
  
    @IBAction func logOutButtonDidTap(_ sender: Any) {        
        AuthHelper.shared.logOut()
    }
        
    // MARK: - Private
    
    private func profileConfig() {
        guard let user = Auth.auth().currentUser else { return }
        
        userNameLabel.text = user.displayName
        userEmailLabel.text = user.email
        photoImageView.kf.setImage(with: user.photoURL)
        photoImageView.setRounded()
    }
    
}

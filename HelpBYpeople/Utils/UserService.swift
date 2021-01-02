//
//  UserService.swift
//  HelpBYpeople
//
//  Created by Alexey on 12/1/20.
//

import Foundation
import Firebase

class UserService {
    
    static var currentUserProfile: UserProfile?
    
    static func observeUserProfile(_ uid: String, completion: @escaping ((_ userProfile: UserProfile?) -> Void)) {
        let userRef = Database.database().reference().child("users/profile/\(uid)")
        
        userRef.observe(.value) { (snapshot) in
            var userProfile: UserProfile?
            
            if let dict = snapshot.value as? [String : Any],
               let userName = dict["userName"] as? String,
               let photoUrl = dict["photoUrl"] as? String,
               let url = URL(string: photoUrl) {
                
                userProfile = UserProfile(uid: snapshot.key, userName: userName, photoUrl: url)
            }
            completion(userProfile)
        }
    }
}

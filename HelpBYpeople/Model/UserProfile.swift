//
//  UserProfile.swift
//  HelpBYpeople
//
//  Created by Alexey on 12/1/20.
//

import Foundation

class UserProfile {
    var uid: String
    var userName: String
    var photoUrl: URL
    
    init(uid: String, userName: String, photoUrl: URL) {
        self.uid = uid
        self.userName = userName
        self.photoUrl = photoUrl
    } 
}

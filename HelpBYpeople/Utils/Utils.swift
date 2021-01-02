//
//  Utils.swift
//  HelpBYpeople
//
//  Created by Alexey on 11/22/20.
//

import Foundation
import Firebase

func L10n(_ key: String) -> String {
    NSLocalizedString(key, comment: "")
}

func storageRef(_ key: String) -> StorageReference {
    Storage.storage().reference().child(key)
}

struct Platform {
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
}

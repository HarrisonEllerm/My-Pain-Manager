//
//  User.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 17/04/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import Foundation

struct User {
    let uid: String
    let name: String
    let email: String
    let profileImageURL: String
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid;
        self.name = dictionary["name"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.profileImageURL = dictionary["profileImageURL"] as? String ?? ""
    }
}

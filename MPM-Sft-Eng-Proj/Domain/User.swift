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
    let birthday: String
    let gender: String
    let height: String
    let weight: String
    let profileImageURL: String
    let altProfileImageUrl: String
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid;
        self.name = dictionary["name"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.birthday = dictionary["birthdate"] as? String ?? ""
        self.gender = dictionary["gender"] as? String ?? ""
        self.height = dictionary["height"] as? String ?? ""
        self.weight = dictionary["weight"] as? String ?? ""
        self.profileImageURL = dictionary["profileImageURL"] as? String ?? ""
        self.altProfileImageUrl = dictionary["altProfileImageURL"] as? String ?? ""
    }
}

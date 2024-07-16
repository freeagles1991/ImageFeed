//
//  ProfileBody.swift
//  ImageFeed
//
//  Created by Дима on 19.06.2024.
//

import Foundation

public struct Profile{
    let username: String
    let name: String
    let loginName: String
    let bio: String
    
    public init(username: String, name: String, loginName: String, bio: String) {
            self.username = username
            self.name = name
            self.loginName = loginName
            self.bio = bio
        }
}

//
//  ProfileStorage.swift
//  ImageFeed
//
//  Created by Дима on 20.06.2024.
//

import Foundation

final class ProfileStorage{
    private var profile = Profile(
        username: "empty",
        name: "empty",
        loginName: "empty",
        bio: "empty")
    
    func updateProfileData(profile: Profile){
        self.profile = profile
    }
    
    func getProfile() -> Profile{
        return profile
    }
}

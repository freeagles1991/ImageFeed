//
//  ProfileImageResponseBody.swift
//  ImageFeed
//
//  Created by Дима on 24.06.2024.
//

import Foundation

struct ProfileImage: Codable {
    let small: String?
    let medium: String?
    let large: String?
}

struct ProfileImageResponseBody: Codable {
    let profileImage: ProfileImage
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
    
    static func decodeUserAvatarResponse(from data: Data) -> Result<ProfileImage, Error> {
        do {
            let response = try JSONDecoder().decode(ProfileImageResponseBody.self, from: data)
            return .success(response.profileImage)
        } catch {
            return .failure(error)
        }
    }
}

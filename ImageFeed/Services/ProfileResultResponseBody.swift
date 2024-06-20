//
//  ProfileResultBody.swift
//  ImageFeed
//
//  Created by Дима on 19.06.2024.
//

import Foundation

struct ProfileResultResponseBody: Codable {
    let username: String
    let firstName: String
    let lastName: String
    let bio: String
    
    enum CodingKeys: String, CodingKey {
            case username
            case firstName = "first_name"
            case lastName = "last_name"
            case bio
        }
    
    static func decodeProfileResponse(from data: Data) -> Result<ProfileResultResponseBody, Error> {
        do {
            let response = try JSONDecoder().decode(ProfileResultResponseBody.self, from: data)
            return .success(response)
        } catch {
            return .failure(error)
        }
    }
    
    func toProfile() -> Profile {
        return Profile(
            username: self.username,
            name: "\(self.firstName) \(self.lastName)",
            loginName: "@\(self.username)",
            bio: self.bio
        )
    }
}

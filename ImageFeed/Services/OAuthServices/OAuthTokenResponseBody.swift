//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Дима on 14.06.2024.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
    
    static func decodeTokenResponse(from data: Data) -> Result<String, Error> {
        do {
            let response = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
            return .success(response.accessToken)
        } catch {
            return .failure(error)
        }
    }
}

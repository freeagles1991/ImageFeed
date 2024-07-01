//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Дима on 14.06.2024.
//

import Foundation

final class OAuth2TokenStorage {
    private let tokenKey = "bearerToken"
    
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }
}

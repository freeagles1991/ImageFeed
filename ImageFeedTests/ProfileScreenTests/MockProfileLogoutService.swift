//
//  MockLogoutService.swift
//  ImageFeedTests
//
//  Created by Дима on 17.07.2024.
//

import ImageFeed
import Foundation

final class MockProfileLogoutService: ProfileLogoutServiceProtocol {
    var isLogoutCalled: Bool = false
    
    func logout() {
        isLogoutCalled = true
    }
}

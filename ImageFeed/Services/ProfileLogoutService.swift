//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Дима on 05.07.2024.
//

import Foundation
import WebKit
import Kingfisher

final class ProfileLogoutService{
    static let shared = ProfileLogoutService()
    private init() { }
    
    private let oauth2Service = OAuth2Service.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let imageListService = ImagesListService.shared

    func logout() {
        cleanCookies()
        cleanKFCache()
        cleanToken()
        cleanProfile()
        cleanPhotosList()
        
    }

    private func cleanCookies() {
       HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
       WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
          records.forEach { record in
             WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
          }
       }
    }
    
    private func cleanKFCache() {
        ImageCache.default.clearMemoryCache()
        ImageCache.default.clearDiskCache {
            print("Disk cache cleared.")
        }
    }
    
    private func cleanToken() {
        oauth2Service.cleanToken()
    }
    
    private func cleanProfile() {
        profileService.cleanProfile()
        profileImageService.cleanProfilePhoto()
    }
    
    private func cleanPhotosList(){
        imageListService.cleanPhotosList()
    }
}



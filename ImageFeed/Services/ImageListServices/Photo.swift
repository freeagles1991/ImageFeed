//
//  Photo.swift
//  ImageFeed
//
//  Created by Дима on 28.06.2024.
//

import Foundation

public struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
    
    static var emptyPhoto: Photo {
        return Photo(id: "", size: CGSize(), createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
    }
}

extension Photo: Equatable {
    public static func ==(lhs: Photo, rhs: Photo) -> Bool {
            return lhs.id == rhs.id &&
                lhs.size == rhs.size &&
                lhs.createdAt == rhs.createdAt &&
                lhs.welcomeDescription == rhs.welcomeDescription &&
                lhs.thumbImageURL == rhs.thumbImageURL &&
                lhs.largeImageURL == rhs.largeImageURL &&
                lhs.isLiked == rhs.isLiked
        }
}

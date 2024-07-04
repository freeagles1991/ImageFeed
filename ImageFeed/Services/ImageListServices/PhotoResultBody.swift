//
//  PhotoResultBody.swift
//  ImageFeed
//
//  Created by Дима on 28.06.2024.
//

import Foundation

struct LikeResponseBody: Codable {
    let photo: PhotoResultBody
    let user: User
}

struct User: Codable {
    
}

struct UrlsResult: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
    let smallS3: String?

    enum CodingKeys: String, CodingKey {
        case raw
        case full
        case regular
        case small
        case thumb
        case smallS3 = "small_s3"
    }
}

struct PhotoResultBody: Codable{
        let id: String
        let createdAt: String
        let width: Int
        let height: Int
        let likedByUser: Bool
        let description: String?
        let urls: UrlsResult

        enum CodingKeys: String, CodingKey {
            case id
            case createdAt = "created_at"
            case width
            case height
            case likedByUser = "liked_by_user"
            case description
            case urls
        }
    
    static func decodePhotoResultResponse(from data: Data) -> Result<[PhotoResultBody], Error> {
        do {
            let response = try JSONDecoder().decode([PhotoResultBody].self, from: data)
            for photo in response{
                print("Photo id: \(photo.id)")
            }
            return .success(response)
        } catch {
            return .failure(error)
        }
    }
    
    func convertToPhoto() -> Photo? {
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
        let photoBody = Photo(id: self.id,
                                  size: CGSize(width: self.width, height: self.height),
                                  createdAt: dateFormatter.date(from: self.createdAt),
                                  welcomeDescription: self.description,
                                  thumbImageURL: self.urls.thumb,
                                  largeImageURL: self.urls.full,
                                  isLiked: self.likedByUser
        )
        return photoBody
    }
}

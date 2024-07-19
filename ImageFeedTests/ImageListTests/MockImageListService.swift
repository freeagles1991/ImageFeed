//
//  MockImageListService.swift
//  ImageFeedTests
//
//  Created by Дима on 19.07.2024.
//

import ImageFeed
import Foundation

class MockImagesListService: ImagesListServiceProtocol {
    var shouldReturnError = false
    var photos = [Photo]()

    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
        if shouldReturnError {
            let error = NSError()
            completion(.failure(error))
        } else {
            completion(.success(photos))
        }
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        if shouldReturnError {
            let error = NSError()
            completion(.failure(error))
        } else {
            completion(.success(()))
        }
    }
}

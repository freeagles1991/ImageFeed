//
//  ImageListPresenter.swift
//  ImageFeed
//
//  Created by Дима on 17.07.2024.
//

import Foundation

public protocol ImageListPresenterProtocol: AnyObject{
    var view: ImageListViewControllerProtocol? {get set}
    var photos: [Photo] {get set}
    func getPhotos() -> [Photo]
    func setPhotos(_ newPhotos: [Photo])
    func appendPhotos(_ newPhotos: [Photo])
    func getImageListPhotosFromService() -> [Photo]
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
    func updateTableViewAnimated()
}

final class ImageListPresenter: ImageListPresenterProtocol {
    var view: ImageListViewControllerProtocol?
    private let imagesListService = ImagesListService.shared
    internal var photos: [Photo] = []
    
    func getImageListPhotosFromService() -> [Photo] {
        let photos = imagesListService.photos
        return photos
    }
    
    func setPhotos(_ newPhotos: [Photo]) {
        self.photos = newPhotos
    }
    
    func appendPhotos(_ newPhotos: [Photo]) {
        self.photos.append(contentsOf: newPhotos)
    }
    
    func getPhotos() -> [Photo] {
        return self.photos
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        imagesListService.changeLike(photoId: photoId, isLike: isLike) { [weak self] result in
            guard let self = self else { return }
            switch result{
            case .success():
                self.photos = self.imagesListService.photos
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        view?.updateTableViewAnimated(oldPhotosCount: oldCount, newPhotosCount: newCount)
    }
}

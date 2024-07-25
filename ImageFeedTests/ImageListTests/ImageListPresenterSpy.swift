//
//  ImageListPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Дима on 19.07.2024.
//

import ImageFeed
import Foundation
import UIKit

final class ImageListPresenterSpy: ImageListPresenterProtocol {
    var imagesListService: ImageFeed.ImagesListServiceProtocol?
    var view: ImageListViewControllerProtocol?
    var viewDidLoadCalled = false
    var reloadDataCalled = false
    
    var photos: [Photo] = []
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func configureImagesListService(_ imagesListService: ImageFeed.ImagesListServiceProtocol) {
        self.imagesListService = imagesListService
    }
    
    func getPhotos() -> [ImageFeed.Photo] {
        return []
    }
    
    func getPhotoURL(indexPath: Int) -> URL? {
        return nil
    }
    
    func setPhotos(_ newPhotos: [ImageFeed.Photo]) {
        
    }
    
    func appendPhotos(_ newPhotos: [ImageFeed.Photo]) {
        self.photos.append(contentsOf: newPhotos)
    }
    
    func getImageListPhotosFromService() -> [ImageFeed.Photo] {
        return []
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        
    }
    
    func updateTableViewAnimated() {
        
    }
    
    func configCell(for cell: ImageFeed.ImagesListCell, with indexPath: IndexPath, in tableView: UITableView) {
        
    }
    
    func fetchInitialPhotos() {
        imagesListService?.fetchPhotosNextPage { [weak self] result in
            switch result {
            case .success(let newPhotos):
                guard let self = self else { return }
                self.appendPhotos(newPhotos)
                self.reloadDataCalled = true
            case .failure(let error):
                print()
            }
        }
    }
    
    
}

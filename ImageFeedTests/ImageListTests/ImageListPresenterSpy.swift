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
    var view: ImageListViewControllerProtocol?
    var viewDidLoadCalled = false
    
    var photos: [Photo] = []
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func getPhotos() -> [ImageFeed.Photo] {
        return []
    }
    
    func setPhotos(_ newPhotos: [ImageFeed.Photo]) {
    
    }
    
    func appendPhotos(_ newPhotos: [ImageFeed.Photo]) {
    
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

    }
    
    
}

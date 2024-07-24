//
//  ImageListPresenter.swift
//  ImageFeed
//
//  Created by Дима on 17.07.2024.
//

import Foundation

public protocol ImageListPresenterProtocol: AnyObject {
    var view: ImageListViewControllerProtocol? {get set}
    var imagesListService: ImagesListServiceProtocol? {get set}
    var photos: [Photo] {get set}
    var dateFormatter: DateFormatter {get set}
    func viewDidLoad()
    func getPhotos() -> [Photo]
    func setPhotos(_ newPhotos: [Photo])
    func appendPhotos(_ newPhotos: [Photo])
    func getImageListPhotosFromService() -> [Photo]
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
    func updateTableViewAnimated()
    func fetchInitialPhotos()
    func configureImagesListService (_ imagesListService: ImagesListServiceProtocol)
    func getPhotoURL(indexPath: IndexPath) -> URL?
}

final class ImageListPresenter: ImageListPresenterProtocol {
    var view: ImageListViewControllerProtocol?
    internal var imagesListService: ImagesListServiceProtocol?
    internal var photos: [Photo] = []
    
    private var imageListServiceObserver: NSObjectProtocol?
    
    internal lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    func viewDidLoad(){
        configureImagesListService(ImagesListService.shared)
        imageListServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateTableViewAnimated()
        }
    }
    
    func configureImagesListService (_ imagesListService: ImagesListServiceProtocol) {
        self.imagesListService = imagesListService
    }
    
    func getImageListPhotosFromService() -> [Photo] {
        guard let photos = imagesListService?.photos else { return [] }
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
    
    func getPhotoURL(indexPath: IndexPath) -> URL?{
        let url = URL(string: self.photos[indexPath.row].largeImageURL)
        return url
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        imagesListService?.changeLike(photoId: photoId, isLike: isLike) { [weak self] result in
            guard let self = self else { return }
            switch result{
            case .success():
                guard let photos = self.imagesListService?.photos else { return }
                self.photos = photos
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updateTableViewAnimated() {
        guard let photos = self.imagesListService?.photos else { return }
        let oldCount = self.photos.count
        let newCount = photos.count
        self.photos = photos
        view?.updateTableViewAnimated(oldPhotosCount: oldCount, newPhotosCount: newCount)
    }
    
    func fetchInitialPhotos() {
        imagesListService?.fetchPhotosNextPage { [weak self] result in
            switch result {
            case .success(let newPhotos):
                guard let self = self else { return }
                self.appendPhotos(newPhotos)
                self.view?.reloadData()
            case .failure(let error):
                print("Ошибка загрузки фото: \(error)")
            }
        }
    }
}

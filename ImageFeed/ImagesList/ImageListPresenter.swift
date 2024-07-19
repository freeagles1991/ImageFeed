//
//  ImageListPresenter.swift
//  ImageFeed
//
//  Created by Дима on 17.07.2024.
//

import Foundation
import UIKit

public protocol ImageListPresenterProtocol: AnyObject {
    var view: ImageListViewControllerProtocol? {get set}
    var imagesListService: ImagesListServiceProtocol? {get set}
    var photos: [Photo] {get set}
    func viewDidLoad()
    func getPhotos() -> [Photo]
    func setPhotos(_ newPhotos: [Photo])
    func appendPhotos(_ newPhotos: [Photo])
    func getImageListPhotosFromService() -> [Photo]
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
    func updateTableViewAnimated()
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath, in tableView: UITableView)
    func fetchInitialPhotos()
    func configureImagesListService (_ imagesListService: ImagesListServiceProtocol)
}

final class ImageListPresenter: ImageListPresenterProtocol {
    var view: ImageListViewControllerProtocol?
    internal var imagesListService: ImagesListServiceProtocol?
    internal var photos: [Photo] = []
    
    private var imageListServiceObserver: NSObjectProtocol?
    
    private lazy var dateFormatter: DateFormatter = {
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
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath, in tableView: UITableView) {
        let imageIndex = photos[indexPath.row]
        let imageURLString = imageIndex.thumbImageURL
        let imageURL = URL(string: imageURLString)
        
        _ = UIImage(named: "photo_stub")
        
        cell.cellImageView.kf.indicatorType = .activity
        
        cell.cellImageView.kf.cancelDownloadTask()
        cell.cellImageView.kf.setImage(
            with: imageURL,
            placeholder: createPlaceholderImage(forCellWith: tableView.rectForRow(at: indexPath)),
            options: nil) { completition in
                switch completition {
                case .success(_):
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                    self.view?.progressHUDDismiss()
                    print("ImagesListPresenter.configCell: Загрузка фото завершена")
                case .failure(let error):
                    self.view?.progressHUDDismiss()
                    print("ImagesListPresenter.configCell: Загрузка фото НЕ завершена. Код - \(error)")
                }
            }
        
        let isLiked = imageIndex.isLiked
        let likeImage = isLiked ? UIImage(named: "FavoritreActive") : UIImage(named: "FavoritreNoActive")
        cell.likeButton.setImage(likeImage, for: .normal)
        
        guard let imageDate = imageIndex.createdAt else {
            cell.dateLabel.text = dateFormatter.string(from: Date())
            return
        }
        cell.dateLabel.text = dateFormatter.string(from: imageDate)
    }
    
    private func createPlaceholderImage(forCellWith frame: CGRect) -> UIImage {
        let placeholderView = UIView(frame: CGRect(origin: .zero, size: frame.size))
        placeholderView.backgroundColor = .white.withAlphaComponent(0.3)
        
        guard let imageStub = UIImage(named: "photo_stub") else { return UIImage() }
        let imageStubView = UIImageView(image: imageStub)
        imageStubView.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.addSubview(imageStubView)
        
        NSLayoutConstraint.activate([
            imageStubView.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            imageStubView.centerYAnchor.constraint(equalTo: placeholderView.centerYAnchor),
            imageStubView.heightAnchor.constraint(equalToConstant: 75),
            imageStubView.widthAnchor.constraint(equalToConstant: 83)
        ])
        
        placeholderView.layoutIfNeeded()
        
        UIGraphicsBeginImageContextWithOptions(placeholderView.bounds.size, false, 0.0)
        placeholderView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let placeholderImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return placeholderImage ?? UIImage()
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
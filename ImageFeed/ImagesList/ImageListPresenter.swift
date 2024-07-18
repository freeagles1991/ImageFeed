//
//  ImageListPresenter.swift
//  ImageFeed
//
//  Created by Дима on 17.07.2024.
//

import Foundation
import UIKit

public protocol ImageListPresenterProtocol: AnyObject{
    var view: ImageListViewControllerProtocol? {get set}
    var photos: [Photo] {get set}
    func getPhotos() -> [Photo]
    func setPhotos(_ newPhotos: [Photo])
    func appendPhotos(_ newPhotos: [Photo])
    func getImageListPhotosFromService() -> [Photo]
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
    func updateTableViewAnimated()
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath, in tableView: UITableView)
}

final class ImageListPresenter: ImageListPresenterProtocol {
    var view: ImageListViewControllerProtocol?
    private let imagesListService = ImagesListService.shared
    internal var photos: [Photo] = []
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
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
}

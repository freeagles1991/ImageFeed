//
//  ImageListViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Дима on 20.07.2024.
//

import ImageFeed
import Foundation
import UIKit

final class ImagesListViewControllerSpy: UIViewController & ImageListViewControllerProtocol {
    var presenter: ImageFeed.ImageListPresenterProtocol?
    
    var setIsLiked = false
    
    func configure(_ presenter: ImageFeed.ImageListPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    func updateTableViewAnimated(oldPhotosCount: Int, newPhotosCount: Int) {
    
    }
    
    func reloadData() {
        
    }
    
    func progressHUDDismiss() {
        
    }
    
    func imageListCellDidTapLike(_ cell: ImageFeed.ImagesListCell) {
        setIsLiked = true
        presenter?.changeLike(photoId: "", isLike: true) { [weak self] result in
            switch result{
            case .success(()):
                print()
            case .failure(let error):
                guard let self = self else { return }
                self.setIsLiked = false
            }
        }
    }
    
    
}

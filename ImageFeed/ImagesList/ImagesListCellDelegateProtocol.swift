//
//  ImagesListCellDelegateProtocol.swift
//  ImageFeed
//
//  Created by Дима on 03.07.2024.
//

import Foundation

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

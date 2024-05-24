//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Дима on 12.05.2024.
//

import Foundation
import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var cellImage: UIImageView!
    
    @IBOutlet var likeButton: UIButton!

    @IBOutlet var dateLabel: UILabel!
    
    private let gradientLayer = CAGradientLayer()
    private let gradientHeight: CGFloat = 30.0 // Фиксированная высота градиента

    override func awakeFromNib() {
         super.awakeFromNib()
         setupGradientLayer()
     }

     private func setupGradientLayer() {
         gradientLayer.colors = [
             UIColor.clear.cgColor,
             UIColor.black.withAlphaComponent(0.5).cgColor
         ]
         gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
         gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
         cellImage.layer.addSublayer(gradientLayer)
     }

    override func layoutSubviews() {
            super.layoutSubviews()
            // Обновляем фрейм градиентного слоя, чтобы он был на дне изображения и имел фиксированную высоту
            let gradientFrame = CGRect(
                x: 0,
                y: cellImage.bounds.height - gradientHeight,
                width: cellImage.bounds.width,
                height: gradientHeight
            )
            gradientLayer.frame = gradientFrame
        }
    
}

//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Дима on 12.05.2024.
//

import Foundation
import UIKit

final public class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    weak var delegate: ImagesListCellDelegate?
    
    @IBOutlet var cellImageView: UIImageView!
    
    @IBOutlet var likeButton: UIButton!

    @IBOutlet var dateLabel: UILabel!
    
    private let gradientLayer = CAGradientLayer()
    private let gradientHeight: CGFloat = 30.0 // Фиксированная высота градиента

    public override func awakeFromNib() {
         super.awakeFromNib()
         setupGradientLayer()
     }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let gradientFrame = CGRect(
            x: 0,
            y: cellImageView.bounds.height - gradientHeight,
            width: cellImageView.bounds.width,
            height: gradientHeight
        )
        gradientLayer.frame = gradientFrame
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImageView.kf.cancelDownloadTask()
    }

    private func setupGradientLayer() {
         gradientLayer.colors = [
             UIColor.clear.cgColor,
             UIColor.black.withAlphaComponent(0.5).cgColor
         ]
         gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
         gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
         cellImageView.layer.addSublayer(gradientLayer)
    }
    
    private func setupImageView() {
        contentView.addSubview(cellImageView)
        
        // Установка ограничений для центрирования UIImageView
        NSLayoutConstraint.activate([
            cellImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            cellImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            cellImageView.widthAnchor.constraint(equalToConstant: 100),  // Укажите желаемую ширину
            cellImageView.heightAnchor.constraint(equalToConstant: 100)  // Укажите желаемую высоту
        ])
    }
    
    func setIsLiked(isLiked: Bool){
        let likeImage = isLiked ? UIImage(named: "FavoritreActive") : UIImage(named: "FavoritreNoActive")
        likeButton.setImage(likeImage, for: .normal)
    }
    
    @IBAction func likeButtonClicked(_ sender: UIButton) {
        delegate?.imageListCellDidTapLike(self)
    }
}

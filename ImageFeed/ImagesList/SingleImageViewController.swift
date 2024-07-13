//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Дима on 18.05.2024.
//

import Foundation
import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController{
    var imageUrl: URL? {
        didSet {
            guard isViewLoaded else { return }
            self.loadImage()
        }
    }
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            guard let image = image else { return }
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    private let alertService = AlertService.shared
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var backwardButton: UIButton!
    
    @IBOutlet private var scrollView: UIScrollView!
    
    @IBOutlet var sharingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertService.singleImageVCDelegate = self
        self.loadImage()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.5
    }
    
    //Тап по кнопке "Назад"
    @IBAction private func didTapBackwardButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //Тап по кнопке "Поделиться"
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image = image else {
            assertionFailure("Не удалось поделиться изображением")
            return }
        let imageToShare = [image]
        presentActivityViewController(from: self, with: imageToShare)
    }
    
    func loadImage() {
        UIBlockingProgressHUD.show()
        guard let imageUrl = imageUrl else { return }
        imageView.kf.setImage(
            with: imageUrl) { [weak self] result in
                UIBlockingProgressHUD.dismiss()
                switch result{
                case .success(let photo):
                    guard let self = self else { return }
                    self.image = self.imageView.image
                    guard let image = image else { return }
                    imageView.frame.size = image.size
                    rescaleAndCenterImageInScrollView(image: image)
                    print()
                case .failure(let error):
                    print(error)
                    guard let self = self else { return }
                    self.alertService.showAlert(title: "Ошибка", message: "Изображение не загружено", buttonRetryTitle: "Повторить", buttonCloseTitle: "Пропустить")
                }
            }
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func presentActivityViewController(from viewController: UIViewController, with items: [UIImage]) {
        let activityViewController = UIActivityViewController(activityItems: items as [Any], applicationActivities: nil)
        
        viewController.present(activityViewController, animated: true, completion: nil)
    }
}

extension SingleImageViewController: UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}


//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Дима on 18.05.2024.
//

import Foundation
import UIKit

final class SingleImageViewController: UIViewController{
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return } // 1
            imageView.image = image
            guard let image = image else { return }
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var backwardButton: UIButton!
    
    @IBOutlet private var scrollView: UIScrollView!
    
    @IBOutlet var sharingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        guard let image = image else { return }
        imageView.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
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


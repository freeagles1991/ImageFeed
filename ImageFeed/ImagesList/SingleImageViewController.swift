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
            imageView.image = image // 2
        }
    }
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var backwardButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
    
    @IBAction private func didTapBackwardButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
}

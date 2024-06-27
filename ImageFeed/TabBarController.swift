//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Дима on 27.06.2024.
//

import Foundation
import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
            
        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        )
            
        let profileViewController = storyboard.instantiateViewController(
            withIdentifier: "ProfileViewController"
        )
        
    self.viewControllers = [imagesListViewController, profileViewController]
    }
}

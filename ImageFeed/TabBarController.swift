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
            
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
                       title: "",
                       image: UIImage(named: "tab_profile_active"),
                       selectedImage: nil
                   )
        
    self.viewControllers = [imagesListViewController, profileViewController]
    }
}

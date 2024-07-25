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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let viewControllers = self.viewControllers else { return }

        for viewController in viewControllers {
            configureProfileViewController(viewController)
            configureImageListViewController(viewController)
        }
    }
    
    private func configureProfileViewController(_ viewController: UIViewController) {
        if let profileViewController = viewController as? ProfileViewController {
            let presenter = ProfilePresenter()
            profileViewController.configure(presenter)
        }
    }

    private func configureImageListViewController(_ viewController: UIViewController) {
        if let imageListViewController = viewController as? ImagesListViewController {
            let presenter = ImageListPresenter()
            imageListViewController.configure(presenter)
        }
    }
}

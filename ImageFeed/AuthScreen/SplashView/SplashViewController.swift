//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Дима on 12.06.2024.
//

import Foundation
import UIKit

final class SplashViewController: UIViewController{
    private let segueIdentifier = "showAuthenticationScreen"
    let oauth2Service = OAuth2Service.shared
    let profileService = ProfileService.shared
    let profileImageService = ProfileImageService.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if oauth2Service.getToken() != nil {
            //TO DO: здесь тестово обновляется профиль
            guard let token = oauth2Service.getToken() else { return }
            self.fetchProfile(token)
            //
            //self.switchToTabBarController()
        } else {
            performSegue(withIdentifier: segueIdentifier, sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier {
            
            guard
                let navigationController = segue.destination as? UINavigationController,
                let authViewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(segueIdentifier)")
                return
            }
            
            authViewController.delegate = self
            
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
           
        window.rootViewController = tabBarController
    }
    
}

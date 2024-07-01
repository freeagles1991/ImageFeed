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
    private let splashImage = UIImage(named: "auth_screen_logo")
    private var splashImageView = UIImageView()
    
    let oauth2Service = OAuth2Service.shared
    let profileService = ProfileService.shared
    let profileImageService = ProfileImageService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSplashImageView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let token = oauth2Service.getToken() {
            self.fetchProfile(token)
        } else {
            guard let navigationController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController else { return }
            guard let authViewController = navigationController.viewControllers.first as? AuthViewController else { return }
            authViewController.delegate = self
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true)
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
    
    private func setupSplashImageView(){
        let imageView = UIImageView(image: splashImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        self.splashImageView = imageView
    }
    
}

//
//  SplashViewController+AuthViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Дима on 14.06.2024.
//

import Foundation
import UIKit
import ProgressHUD

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
            UIBlockingProgressHUD.show()
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code: code) { result in
            //guard let self = self else { return }
            switch result {
            case .success:
                UIBlockingProgressHUD.dismiss()
            case .failure:
                // TODO [Sprint 11]
                break
            }
        }
    }
    
    func fetchProfile(_ token: String){
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success:
                self.switchToTabBarController()
                guard let username = profileService.profile?.username else { return }
                self.profileImageService.fetchProfileImageURL(username: username) { result in
                    switch result{
                    case .success:
                        print("User avatar recieved")
                    case .failure:
                        //TODO
                        break
                    }}
            case .failure:
                // TODO [Sprint 11] Покажите ошибку получения профиля
                break
            }
        }
    }
    
    func fetchImageProfile(_ username: String){
        profileImageService.fetchProfileImageURL(username: username) { result in
            switch result {
            case .success:
                print("Успешно загружен аватар")
            case .failure:
                // TODO [Sprint 11] Покажите ошибку получения профиля
                break
            }
        }
    }
    
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        guard let token = tokenStorage.token else { return }
        self.fetchProfile(token)
        
        //self.switchToTabBarController()
    }
}

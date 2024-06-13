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
    private let storage = OAuth2TokenStorage()
    private let oauth2Service = OAuth2Service.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Здесь делаем проверку на авторизацию пользователя. Если есть, то переходим сразу на таблицу
        if let token = storage.token {
            self.switchToTabBarController()
        }
        
        else {
            //Если нет - то переход на авторизацию
            performSegue(withIdentifier: segueIdentifier, sender: nil)
        }
    }
    
    private func switchToTabBarController() {
        // Получаем экземпляр `window` приложения
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        // Создаём экземпляр нужного контроллера из Storyboard с помощью ранее заданного идентификатора
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
           
        // Установим в `rootViewController` полученный контроллер
        window.rootViewController = tabBarController
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Проверим, что переходим на авторизацию
        if segue.identifier == segueIdentifier {
            
            // Доберёмся до первого контроллера в навигации. Мы помним, что в программировании отсчёт начинается с 0?
            guard
                let navigationController = segue.destination as? UINavigationController,
                let authViewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(segueIdentifier)")
                return
            }
            
            // Установим делегатом контроллера наш SplashViewController
            authViewController.delegate = self
            
        }
        else
        {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        self.switchToTabBarController()
    }
    
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.switchToTabBarController()
            case .failure:
                // TODO [Sprint 11]
                break
            }
        }
    }
}

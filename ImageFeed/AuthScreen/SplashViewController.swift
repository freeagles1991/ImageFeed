//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Дима on 12.06.2024.
//

import Foundation
import UIKit

final class SplashViewController: UIViewController{
    private let segueIdentifier = "showAuthenticationScreenSegueIdentifier"
    private let storage = OAuth2TokenStorage()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Здесь делаем проверку на авторизацию пользователя. Если есть, то переходим сразу на таблицу
        print(storage.token)
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
    
}

extension SplashViewController: AuthViewControllerDelegate{
    
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
            authViewController.authViewControllerDelegate = self
            
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

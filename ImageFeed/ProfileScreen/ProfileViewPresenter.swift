//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Дима on 15.07.2024.
//

import Foundation

protocol ProfilePresenterProtocol: AnyObject{
    var view: ProfileViewViewControllerProtocol? {get set}
    func viewDidLoad()
    func logout()
    func logoutButtonTap()
}

final class ProfileViewPresenter: ProfilePresenterProtocol {
    var view: ProfileViewViewControllerProtocol?
    private let profileLogoutService = ProfileLogoutService.shared
    private let alertService = AlertService.shared
    
    func viewDidLoad() {
        alertService.profileVCDelegate = self
    }
    
    func logoutButtonTap() {
        alertService.showAlert(title: "Пока!", message: "Точно хотите выйти?", buttonConfirmTitle: "Да, ухожу", buttonDeclineTitle: "Нет, остаюсь")
    }
    
    func logout(){
        UIBlockingProgressHUD.show()
        profileLogoutService.logout()
        let splashViewCotroller = SplashViewController()
        splashViewCotroller.modalPresentationStyle = .fullScreen
        view?.present(splashViewCotroller, animated: true, completion: nil)
        UIBlockingProgressHUD.dismiss()
    }
}
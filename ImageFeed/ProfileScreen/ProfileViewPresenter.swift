//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Дима on 15.07.2024.
//

import Foundation
import UIKit
import Kingfisher

protocol ProfilePresenterProtocol: AnyObject{
    var view: ProfileViewViewControllerProtocol? {get set}
    func viewDidLoad()
    func logout()
    func logoutButtonTap()
    func updateProfileDetails() -> Profile
    func loadAvatar(completion: @escaping (UIImage?) -> Void)
}

final class ProfileViewPresenter: ProfilePresenterProtocol {
    var view: ProfileViewViewControllerProtocol?
    private let profileLogoutService = ProfileLogoutService.shared
    private let alertService = AlertService.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    func viewDidLoad() {
        alertService.profileVCDelegate = self
    }
    
    func updateProfileDetails() -> Profile {
        guard let profile = profileService.profile else { return Profile(username: "empty", name: "empty", loginName: "empty", bio: "empty") }
        return profile
    }
    
    func loadAvatar(completion: @escaping (UIImage?) -> Void) {
        guard let url = self.getProfileAvatarURL() else { return completion(nil) }
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case .success(let value):
                // Присваиваем загруженное изображение переменной
                completion(value.image)
            case .failure(let error):
                print("Ошибка загрузки изображения: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    private func getProfileAvatarURL() -> URL? {
        guard
            let profileImageURL = profileImageService.smallAvatarURL,
            let url = URL(string: profileImageURL)
        else {
            return nil
        }
        return url
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

//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Дима on 15.07.2024.
//

import Foundation

public protocol ProfilePresenterProtocol: AnyObject{
    var view: ProfileViewViewControllerProtocol? {get set}
    var profile: Profile? {get set}
    func viewDidLoad()
    func logout()
    func logoutButtonTap()
    func updateProfileDetails()
    func getProfileAvatarURL() -> URL?
}

final class ProfilePresenter: ProfilePresenterProtocol {
    var profile: Profile?
    var view: ProfileViewViewControllerProtocol?
    private var profileLogoutService: ProfileLogoutServiceProtocol?
    private let alertService = AlertService.shared
    private var profileService: ProfileServiceProtocol?
    private var profileImageService: ProfileImageServiceProtocol?
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    func viewDidLoad() {
        configureProfileService(ProfileService.shared)
        configureProfileLogoutService(ProfileLogoutService.shared)
        configureProfileImageService(ProfileImageService.shared)
        alertService.profileVCDelegate = self
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak view] _ in
            guard let view = view else { return }
            view.updateAvatar()
        }
        view?.updateAvatar()
    }
    
    func configureProfileService(_ profileService: ProfileServiceProtocol) {
        self.profileService = profileService
    }
    
    func configureProfileLogoutService(_ profileLogoutService: ProfileLogoutServiceProtocol) {
        self.profileLogoutService = profileLogoutService
    }
    
    func configureProfileImageService(_ profileImageService: ProfileImageServiceProtocol) {
        self.profileImageService = profileImageService
    }
    
    func updateProfileDetails() {
        guard let profile = profileService?.profile else { return }
        self.profile = profile
    }
    
    internal func getProfileAvatarURL() -> URL? {
        guard
            let profileImageURL = profileImageService?.smallAvatarURL,
            let url = URL(string: profileImageURL)
        else {
            return nil
        }
        return url
    }
    
    func fetchProfileAvatarURL() -> URL? {
        return self.getProfileAvatarURL()
    }
    
    
    func logoutButtonTap() {
        alertService.showAlert(title: "Пока!", message: "Точно хотите выйти?", buttonConfirmTitle: "Да, ухожу", buttonDeclineTitle: "Нет, остаюсь")
    }
    
    func logout(){
        UIBlockingProgressHUD.show()
        profileLogoutService?.logout()
        let splashViewCotroller = SplashViewController()
        splashViewCotroller.modalPresentationStyle = .fullScreen
        view?.present(splashViewCotroller, animated: true, completion: nil)
        UIBlockingProgressHUD.dismiss()
    }
}

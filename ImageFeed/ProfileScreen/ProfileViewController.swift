//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Дима on 16.05.2024.
//

import Foundation
import UIKit
import Kingfisher

protocol ProfileViewViewControllerProtocol: UIViewController {
    var presenter: ProfilePresenterProtocol? { get set }
}

final class ProfileViewController: UIViewController & ProfileViewViewControllerProtocol {
    
    private var nameLabel: UILabel?
    private var loginLabel: UILabel?
    private var statusLabel: UILabel?
    private var exitButtonView: UIButton?
    private var profileImageView = UIImageView()
    private var profileImage = UIImage(named: "ProfilePhoto")
    private var profilePlaceholderImage = UIImage(named: "placeholder.jpeg")
    private let profileNameString = "Екатерина Новикова"
    private let emailString = "@ekaterina_nov"
    private let statusString = "Hello, world!"
    
    var presenter: ProfilePresenterProtocol?
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure(ProfileViewPresenter())
        presenter?.viewDidLoad()
        
        self.setupProfileImageView()
        self.setupNameLabel()
        self.setupEmailLabel()
        self.setupStatusLabel()
        self.setupExitbutton()
        self.updateProfileDetails()

        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
                        forName: ProfileImageService.didChangeNotification,
                       object: nil,
                       queue: .main
                   ) { [weak self] _ in
                       guard let self = self else { return }
                       self.updateAvatar()
                   }
               updateAvatar()
    }
    
    ///Конфигурируем Presenter  и Viewer
    func configure(_ presenter: ProfilePresenterProtocol) {
             self.presenter = presenter
             presenter.view = self
         }
    
    private func setupProfileImageView(){
        let imageView = UIImageView(image: profileImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        
        self.profileImageView = imageView
    }
    
    private func setupNameLabel(){
        let label = UILabel()
        let font = UIFont(name: "SF Pro", size: 23)
        label.text = profileNameString
        label.textColor = .white
        label.font = font
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        label.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8).isActive = true
        label.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor).isActive = true
        
        self.nameLabel = label
    }
    
    private func setupEmailLabel(){
        let label = UILabel()
        let font = UIFont(name: "SF Pro", size: 13)
        label.text = emailString
        label.textColor = .gray
        label.font = font
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        guard let nameLabel = self.nameLabel else { return }
        label.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        label.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor).isActive = true
        
        self.loginLabel = label
    }
    
    private func setupStatusLabel(){
        let label = UILabel()
        let font = UIFont(name: "SF Pro", size: 13)
        label.text = statusString
        label.textColor = .white
        label.font = font
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        guard let emailLabel = self.loginLabel else { return }
        label.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8).isActive = true
        label.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor).isActive = true
        
        self.statusLabel = label
    }
    
    private func setupExitbutton(){
        let exitButtonView = UIButton(type: .custom)
        exitButtonView.setImage(UIImage(named: "LogoutIcon"), for: .normal)
        exitButtonView.addTarget(self, action: #selector(logoutButtonTap), for: .touchUpInside)
        
        exitButtonView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButtonView)
        
        exitButtonView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        exitButtonView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        exitButtonView.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        exitButtonView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        
        self.exitButtonView = exitButtonView
    }
    
    private func updateProfileDetails(){
        guard let profile = presenter?.updateProfileDetails() else { return }
        nameLabel?.text = profile.name
        statusLabel?.text = profile.bio
        loginLabel?.text = profile.loginName
    }
    
    private func updateAvatar() {
        self.profileImageView.image = profilePlaceholderImage
        presenter?.loadAvatar() { [weak self] result in
            if let downloadedImage = result {
                guard let self = self else { return }
                self.profileImage = downloadedImage
                self.profileImageView.image = self.profileImage
                print("Изображение загружено и присвоено переменной.")
            } else {
                print("Ошибка загрузки изображения.")
            }
        }
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        }
    
    @IBAction private func logoutButtonTap(_ sender: UIButton) {
        presenter?.logoutButtonTap()
    }
}

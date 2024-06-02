//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Дима on 16.05.2024.
//

import Foundation
import UIKit

final class ProfileViewController: UIViewController {
    
    private var nameLabel: UILabel?
    private var emailLabel: UILabel?
    private var statusLabel: UILabel?
    private var profileImageView = UIImageView()
    private let profileImage = UIImage(named: "ProfilePhoto")
    private let profileNameString = "Екатерина Новикова"
    private let emailString = "@ekaterina_nov"
    private let statusString = "Hello, world!"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupProfileImageView()
        self.setupNameLabel()
        self.setupEmailLabel()
        self.setupStatusLabel()
        self.setupExitbutton()
        
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
        
        self.emailLabel = label
    }
    
    private func setupStatusLabel(){
        let label = UILabel()
        let font = UIFont(name: "SF Pro", size: 13)
        label.text = statusString
        label.textColor = .white
        label.font = font
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        guard let emailLabel = self.emailLabel else { return }
        label.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8).isActive = true
        label.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor).isActive = true
        
        self.statusLabel = label
    }
    
    private func setupExitbutton(){
        let exitButtonView = UIButton(type: .custom)
        exitButtonView.setImage(UIImage(named: "LogoutIcon"), for: .normal)
        exitButtonView.addTarget(self, action: #selector(self.didTapButton), for: .touchUpInside)
        
        exitButtonView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButtonView)
        
        exitButtonView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        exitButtonView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        exitButtonView.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        exitButtonView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
    }
    
    @objc
    private func didTapButton() {
        print("Tap exit buttton")
    }
}

//
//  ProfileViewPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Дима on 16.07.2024.
//

import ImageFeed
import Foundation
import UIKit

final class ProfilePresenterSpy: ProfilePresenterProtocol {    
    var profile: ImageFeed.Profile?
    
    var view: ProfileViewViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func logout() {
    
    }
    
    func logoutButtonTap() {
    
    }
    
    func loadAvatar(completion: @escaping (UIImage?) -> Void) {
        
    }
    
    func updateProfileDetails() {
        
    }
    
}

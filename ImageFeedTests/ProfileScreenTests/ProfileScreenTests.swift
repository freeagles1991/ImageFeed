//
//  ProfileScreenTests.swift
//  ImageFeedTests
//
//  Created by Дима on 16.07.2024.
//
@testable import ImageFeed
import XCTest

final class ProfileScreenTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.configure(presenter)
        
        //when
         _ = viewController.view
         
         //then
         XCTAssertTrue(presenter.viewDidLoadCalled) //behaviour verification
    }
    
    ///Проверяем, что updateProfileDetails не изменяет профиль, если profileService.profile равно nil
    func testUpdateProfileDetails_WithNilProfile() {
        //given
        let mockProfileService = MockProfileService()
        mockProfileService.profile = nil
        let viewController = ProfileViewController()
        let presenter = ProfilePresenter()
        viewController.configure(presenter)
        presenter.configureProfileService(mockProfileService)

        let initialProfile = Profile(username: "username", name: "name", loginName: "loginName", bio: "bio")
        presenter.profile = initialProfile

        //when
        presenter.updateProfileDetails()

        //then
        XCTAssertEqual(presenter.profile?.username, initialProfile.username)
        XCTAssertEqual(presenter.profile?.name, initialProfile.name)
        XCTAssertEqual(presenter.profile?.loginName, initialProfile.loginName)
        XCTAssertEqual(presenter.profile?.bio, initialProfile.bio)
    }
    
    func testUpdateProfileDetails_WithNoNilProfile() {
        //given
        let mockProfileService = MockProfileService()
        let viewController = ProfileViewController()
        let presenter = ProfilePresenter()
        viewController.configure(presenter)
        presenter.configureProfileService(mockProfileService)

        let initialProfile = Profile(username: "username", name: "name", loginName: "loginName", bio: "bio")
        mockProfileService.profile = initialProfile

        //when
        presenter.updateProfileDetails()

        //then
        XCTAssertEqual(presenter.profile?.username, initialProfile.username)
        XCTAssertEqual(presenter.profile?.name, initialProfile.name)
        XCTAssertEqual(presenter.profile?.loginName, initialProfile.loginName)
        XCTAssertEqual(presenter.profile?.bio, initialProfile.bio)
    }
    
    func testLogout_ProfileLogoutServiceCalled() {
        //given
        let mockLogoutService = MockProfileLogoutService()
        let viewController = ProfileViewController()
        let presenter = ProfilePresenter()
        viewController.configure(presenter)
        presenter.configureProfileLogoutService(mockLogoutService)

        //when
        presenter.logout()

        //then
        XCTAssertTrue(mockLogoutService.isLogoutCalled)
    }
    
    func testFetchProfileImageURL_ProfileImageServiceURL() {
        //given
        let mockProfileImageService = MockProfileImageService()
        let viewController = ProfileViewController()
        let presenter = ProfilePresenter()
        viewController.configure(presenter)
        presenter.configureProfileImageService(mockProfileImageService)
        
        guard let avatarURL = mockProfileImageService.smallAvatarURL else { return }
        let mockURL = URL(string: avatarURL)

        //when
        let url = presenter.fetchProfileAvatarURL()

        //then
        XCTAssertEqual(url, mockURL)
    }
    
    func testViewControllerCallsUpdateAvatar_Success() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.configure(presenter)
        presenter.isAvatarLoadedSuccess = true
        
        //when
        viewController.updateAvatar()
         
         //then
        XCTAssertTrue(presenter.loadAvatarCalled)
        XCTAssertEqual(viewController.getProfileImageView()?.image, presenter.mockUIImage)
    }
    
    func testViewControllerCallsUpdateAvatar_Failure() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.configure(presenter)
        presenter.isAvatarLoadedSuccess = false
        
        //when
        viewController.updateAvatar()
         
         //then
        XCTAssertTrue(presenter.loadAvatarCalled)
        XCTAssertNotEqual(viewController.getProfileImageView()?.image, presenter.mockUIImage)
    }
}


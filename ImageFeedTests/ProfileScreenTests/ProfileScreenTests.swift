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
    
    func testExample() throws {
        
    }
}

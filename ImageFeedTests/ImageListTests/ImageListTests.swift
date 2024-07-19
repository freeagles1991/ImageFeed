//
//  ImageListTests.swift
//  ImageFeedTests
//
//  Created by Дима on 19.07.2024.
//

@testable import ImageFeed
import XCTest

final class ImageListTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImageListPresenterSpy()
        viewController.configure(presenter)
        
        //when
         _ = viewController.view
         
         //then
         XCTAssertTrue(presenter.viewDidLoadCalled) //behaviour verification
    }
    
    func testFetchInitialPhotosSuccess() {
        // Given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        viewController.loadViewIfNeeded()
        let presenter = ImageListPresenterSpy()
        viewController.configure(presenter)
        let mockImagesListService = MockImagesListService()
        presenter.configureImagesListService(mockImagesListService)
        let expectedPhotos = [Photo.emptyPhoto, Photo.emptyPhoto]
        mockImagesListService.photos = expectedPhotos

        // When
        presenter.fetchInitialPhotos()

        // Then
        XCTAssertEqual(presenter.photos, expectedPhotos)
        XCTAssertTrue(presenter.reloadDataCalled)
    }
    
    func testFetchInitialPhotosFailure() {
        // Given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        viewController.loadViewIfNeeded()
        let presenter = ImageListPresenterSpy()
        viewController.configure(presenter)
        let mockImagesListService = MockImagesListService()
        presenter.configureImagesListService(mockImagesListService)
        mockImagesListService.shouldReturnError = true
        

        // When
        presenter.fetchInitialPhotos()

        // Then
        XCTAssertFalse(presenter.reloadDataCalled)
    }
}

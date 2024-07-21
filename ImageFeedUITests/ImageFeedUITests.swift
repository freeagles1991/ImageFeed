//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Дима on 03.05.2024.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }

    func testAuth() throws {
        let authenticateButton = app.buttons["Authenticate"]
        XCTAssertTrue(authenticateButton.waitForExistence(timeout: 10), "Кнопка 'Authenticate' не появилась вовремя")
        authenticateButton.tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 10), "Экран авторизации не появился вовремя")
        let startPoint = webView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        
        //Находим поля ввода
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("")
        startPoint.referencedElement.swipeUp()

        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        // Ввести пароль
            if passwordTextField.hasFocus {
                passwordTextField.typeText("")
            } else {
                passwordTextField.tap()
                passwordTextField.typeText("")
            }
        webView.swipeUp()
        
        // Нажать кнопку логина
        webView.buttons["Login"].tap()
        
        //Ждем появления ячеек таблицы
        sleep(2)
        let tablesQuery = app.tables
        
        // Проверяем наличие первой ячейки
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 10), "Первая ячейка таблицы не появилась вовремя")
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        cellToLike.buttons["like button off"].tap(withNumberOfTaps: 1, numberOfTouches: 1)
        sleep(2)
        cellToLike.buttons["like button on"].tap(withNumberOfTaps: 1, numberOfTouches: 1)
        
        
        
        sleep(2)
        
        cellToLike.tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        // Zoom in
        image.pinch(withScale: 3, velocity: 1) // zoom in
        // Zoom out
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["nav back button white"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
       
        XCTAssertTrue(app.staticTexts["Dmitry Nerovny"].exists)
        XCTAssertTrue(app.staticTexts["@freeagles"].exists)
        
        let logoutButton = app.buttons["Logout button"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 10), "Кнопка 'Logout button' не появилась вовремя")
        logoutButton.tap()
        
        app.alerts["Пока!"].scrollViews.otherElements.buttons["Да, ухожу"].tap()
    }
}

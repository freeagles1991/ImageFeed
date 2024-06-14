//
//  AuthViewControllerDelegateProtocol.swift
//  ImageFeed
//
//  Created by Дима on 14.06.2024.
//

import Foundation

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

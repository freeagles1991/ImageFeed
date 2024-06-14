//
//  WebViewViewControllerDelegateProtocol.swift
//  ImageFeed
//
//  Created by Дима on 14.06.2024.
//

import Foundation
import UIKit

protocol WebViewViewControllerDelegate: UIViewController{
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

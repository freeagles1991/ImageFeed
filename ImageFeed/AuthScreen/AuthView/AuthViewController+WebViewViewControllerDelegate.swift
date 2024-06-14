//
//  AuthViewController+WebViewViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Дима on 14.06.2024.
//

import Foundation

extension AuthViewController: WebViewViewControllerDelegate{
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}

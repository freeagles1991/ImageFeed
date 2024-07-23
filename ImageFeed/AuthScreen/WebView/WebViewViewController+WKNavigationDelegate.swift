//
//  WebViewViewController+WKNavigationDelegate.swift
//  ImageFeed
//
//  Created by Дима on 14.06.2024.
//

import Foundation
import UIKit
import WebKit

extension WebViewViewController: WKNavigationDelegate{
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            print(code)
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}

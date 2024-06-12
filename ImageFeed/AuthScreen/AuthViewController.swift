//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Дима on 04.06.2024.
//

import Foundation
import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController{
    weak var webViewControllerDelegate: WebViewViewControllerDelegate?
    weak var authViewControllerDelegate: AuthViewControllerDelegate?
    let oAuth2Service: OAuth2Service? = OAuth2Service.shared
    override func viewDidLoad() {
           super.viewDidLoad()
           print("viewDidLoad called")
           configureBackButton()
       }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        super.prepare(for: segue, sender: sender)
        self.webViewControllerDelegate = self
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "colorBlack")
    }
}

extension AuthViewController: WebViewViewControllerDelegate{
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        oAuth2Service?.fetchOAuthToken(code: code) { result in
            switch result{
            case .success(let token):
                self.authViewControllerDelegate?.didAuthenticate(self)
                print("token successfully received")
            case .failure(let error):
                print("Error: token not received")
            }
            
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        self.navigationController?.popViewController(animated: true)
    }
}

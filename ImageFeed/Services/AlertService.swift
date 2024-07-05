//
//  AlertService.swift
//  ImageFeed
//
//  Created by Дима on 04.07.2024.
//

import Foundation
import UIKit

final class AlertService {
    static let shared = AlertService()
    private init() {}
    
    weak var delegate: UIViewController?
    weak var singleImageVCDelegate: SingleImageViewController?
    
    func showAlert(title: String, message: String, buttonTitle: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: buttonTitle, style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            print("AlertService.showAlert: OK button tapped")
        }
        
        alertController.addAction(okAction)
        
        delegate?.present(alertController, animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String, buttonRetryTitle: String, buttonCloseTitle: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let retryAction = UIAlertAction(title: buttonRetryTitle, style: .default) { [weak self] _ in
            alertController.dismiss(animated: true, completion: nil)
            guard let self = self else { return }
            self.singleImageVCDelegate?.loadImage()
            print("AlertService.showAlert: \(buttonRetryTitle) button tapped")
        }
        
        let closeAction = UIAlertAction(title: buttonCloseTitle, style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            print("AlertService.showAlert: \(buttonCloseTitle) button tapped")
        }
        
        
        alertController.addAction(retryAction)
        alertController.addAction(closeAction)
        
        singleImageVCDelegate?.present(alertController, animated: true, completion: nil)
    }
}


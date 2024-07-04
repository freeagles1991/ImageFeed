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
    
    func showAlert(title: String, message: String, buttonTitle: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: buttonTitle, style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            print("AlertService.showAlert: OK button tapped")
        }
        
        alertController.addAction(okAction)
        
        delegate?.present(alertController, animated: true, completion: nil)
    }
}

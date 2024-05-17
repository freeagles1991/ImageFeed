//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Дима on 16.05.2024.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet var logoutrButton: UIButton!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    
    @IBOutlet var profilePhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func tapOnLogoutButton(_ sender: Any) {
    }
}

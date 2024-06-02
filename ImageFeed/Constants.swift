//
//  Constants.swift
//  ImageFeed
//
//  Created by Дима on 02.06.2024.
//

import Foundation

private enum Constants{
    static let secretKey: String = "CKGcIl0tMuD-nxV9BmQHA5EyNu6vcmKH3mUGsNxnE2k"
    static let accessKey: String = "5GFfRF7aetPQVZVSc1lC_kjv8Lx4GhibtvrGVaSPmbk"
    static let redirectURI: String = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope: String = "public+read_user+write_likes"
    static let defaultBaseURL: URL = URL(string: "https://api.unsplash.com/")!
}

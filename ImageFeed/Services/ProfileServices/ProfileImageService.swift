//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Дима on 24.06.2024.
//

import Foundation

final class ProfileImageService{
    static let shared = ProfileImageService()
    private init() {}
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private (set) var smallAvatarURL: String?
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String?, Error>) -> Void){
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard let request = makeProfileAvatarRequest(username) else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.urlSessionError))
            }
            print("Invalid request")
            return
        }
        
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                let decodeResult = ProfileImageResponseBody.decodeUserAvatarResponse(from: data)
                switch decodeResult {
                case .success(let profileImages):
                    self.smallAvatarURL = profileImages.small
                    guard let smallAvatarURL = self.smallAvatarURL else { return }
                    DispatchQueue.main.async {
                        completion(.success(smallAvatarURL))
                        NotificationCenter.default.post(
                                name: ProfileImageService.didChangeNotification,
                                object: self,
                                userInfo: ["URL": smallAvatarURL])
                    }
                    print("Profile received")
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    print("Error during profile decoding")
                }
            case .failure(let error):
                switch error {
                case NetworkError.httpStatusCode(let statusCode):
                    print("HTTP Error: status-code \(statusCode)")
                case NetworkError.urlRequestError(let requestError):
                    print("Request error: \(requestError.localizedDescription)")
                case NetworkError.urlSessionError:
                    print("URLSession Error")
                default:
                    print("Unknown error: \(error.localizedDescription)")
                }
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    private func makeProfileAvatarRequest(_ username: String) -> URLRequest?{
        guard let url = URL(string: "https://api.unsplash.com/user/\(username)") else {
            print("Invalid base URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        guard let token = oauth2TokenStorage.token
        else {
            print("No token")
            return nil}
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

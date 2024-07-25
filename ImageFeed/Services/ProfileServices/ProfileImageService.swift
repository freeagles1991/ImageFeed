//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Дима on 24.06.2024.
//

import Foundation

public protocol ProfileImageServiceProtocol: AnyObject {
    var smallAvatarURL: String? { get }
}

final class ProfileImageService: ProfileImageServiceProtocol {
    static let shared = ProfileImageService()
    private init() {}
    
    private let urlSession = URLSession.shared
    private let oauthService = OAuth2Service.shared
    private var task: URLSessionTask?
    
    private (set) var smallAvatarURL: String?
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String?, Error>) -> Void){
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard let request = makeProfileAvatarRequest(username) else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.urlSessionError))
            }
            print("ProfileImageService.fetchProfileImageURL: сессия прервана")
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { (result: Result<ProfileImageResponseBody, Error>) in
            switch result {
            case .success(let responseBody):
                self.smallAvatarURL = responseBody.profileImage.small
                guard let smallAvatarURL = self.smallAvatarURL else { return }
                DispatchQueue.main.async {
                    completion(.success(smallAvatarURL))
                    NotificationCenter.default.post(
                            name: ProfileImageService.didChangeNotification,
                            object: self,
                            userInfo: ["URL": smallAvatarURL])
                }
                print("ProfileImageService.fetchProfileImageURL: аватар пользователя успешно загружен")
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                switch error {
                case NetworkError.httpStatusCode(let statusCode):
                    print("ProfileImageService.fetchProfileImageURL. HTTP Error: status-code \(statusCode)")
                case NetworkError.urlRequestError(let requestError):
                    print("ProfileImageService.fetchProfileImageURL. Request error: \(requestError.localizedDescription)")
                case NetworkError.urlSessionError:
                    print("ProfileImageService.fetchProfileImageURL. URLSession Error")
                default:
                    print("ProfileImageService.fetchProfileImageURL. Unknown error: \(error.localizedDescription)")
                }
                print("ProfileImageService.fetchProfileImageURL: Ошибка при декодировании ссылки на аватар пользователя")
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    private func makeProfileAvatarRequest(_ username: String) -> URLRequest?{
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            print("Invalid base URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        guard let token = oauthService.getToken()
        else {
            print("No token")
            return nil}
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func cleanProfilePhoto(){
        self.smallAvatarURL = ""
    }
}

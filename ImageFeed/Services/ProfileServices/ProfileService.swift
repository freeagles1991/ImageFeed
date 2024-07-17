//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Дима on 19.06.2024.
//

import Foundation

public protocol ProfileServiceProtocol: AnyObject {
    var profile: Profile? { get }
}

final class ProfileService: ProfileServiceProtocol{
    static let shared = ProfileService()
    private init() {}
    
    private let urlSession = URLSession.shared
    private let oauthService = OAuth2Service.shared
    private var task: URLSessionTask?
    
    private(set) var profile: Profile?
    
    private func makeProfileRequest() -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
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
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void){
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard let request = makeProfileRequest() else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.urlSessionError))
            }
            print("ProfileService.fetchProfile: сессия прервана")
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { (result: Result<ProfileResultResponseBody, Error>) in
            switch result {
            case .success(let responseBody):
                self.profile = responseBody.toProfile()
                guard let profile = self.profile else { return }
                DispatchQueue.main.async {
                    completion(.success(profile))
                }
                print("ProfileService.fetchProfile: профиль успешно загружен")
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                switch error {
                case NetworkError.httpStatusCode(let statusCode):
                    print("ProfileService.fetchProfile. HTTP Error: status-code \(statusCode)")
                case NetworkError.urlRequestError(let requestError):
                    print("ProfileService.fetchProfile. Request error: \(requestError.localizedDescription)")
                case NetworkError.urlSessionError:
                    print("ProfileService.fetchProfile. URLSession Error")
                default:
                    print("ProfileService.fetchProfile. Unknown error: \(error.localizedDescription)")
                }
                print("ProfileService.fetchProfile. Ошибка при декодировании данных")
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    func cleanProfile() {
        self.profile = Profile(username: "", name: "", loginName: "", bio: "")
    }
}

//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Дима on 19.06.2024.
//

import Foundation

final class ProfileService{
    static let shared = ProfileService()
    private init() {}
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    private(set) var profile: Profile?
    
    let oauth2TokenStorage = OAuth2TokenStorage()
    
    private func makeProfileRequest() -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
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
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void){
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard let request = makeProfileRequest() else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.urlSessionError))
            }
            print("Invalid request")
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
                print("Profile received")
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
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
    
}

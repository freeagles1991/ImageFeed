//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Дима on 08.06.2024.
//

import Foundation
    
final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private let oAuth2TokenStorage = OAuth2TokenStorage()
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            print("Invalid base URL")
            return nil
        }
        
        guard let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&client_secret=\(Constants.secretKey)"
            + "&redirect_uri=\(Constants.redirectURI)"
            + "&code=\(code)"
            + "&grant_type=authorization_code",
            relativeTo: baseURL
        ) else {
            print("Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if task != nil {
            if lastCode != code {
                task?.cancel()
            } else {
                completion(.failure(NetworkError.urlSessionError))
                return
            }
        } else {
            if lastCode == code {
                completion(.failure(NetworkError.urlSessionError))
                return
            }
        }
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.urlSessionError))
            }
            print("Invalid request")
            return
        }
        
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                let decodeResult = OAuthTokenResponseBody.decodeTokenResponse(from: data)
                switch decodeResult {
                case .success(let token):
                    self.oAuth2TokenStorage.token = token
                    DispatchQueue.main.async {
                        completion(.success(token))
                    }
                    print("OAuth token received: \(token)")
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    print("Error during token decoding")
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
            self.lastCode = nil
        }
        self.task = task
        task.resume()
    }
}


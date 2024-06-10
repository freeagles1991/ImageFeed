//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Дима on 08.06.2024.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
    
    static func decodeTokenResponse(from data: Data) -> Result<String, Error> {
        do {
            let response = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
            return .success(response.accessToken)
        } catch {
            return .failure(error)
        }
    }
}
    
final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
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
        guard let request = makeOAuthTokenRequest(code: code) else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.urlSessionError))
            }
            print("Invalid request")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                print("Error fetching OAuth token: \(error)")
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.urlSessionError))
                }
                print("No data received")
                return
            }
            
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
                print("Error decoding OAuth token: \(error)")
            }
        }
        task.resume()
    }
}

final class OAuth2TokenStorage {
    private let tokenKey = "bearerToken"
    
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }
}


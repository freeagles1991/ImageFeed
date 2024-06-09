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
             completion(.failure(NetworkError.urlSessionError))
             print("Invalid request")
             return }
         
         let task = URLSession.shared.data(for: request) { result in
             switch result {
             case .success(let data):
                 let decodeResult = OAuthTokenResponseBody.decodeTokenResponse(from: data)
                 completion(decodeResult)
                 print("OAuth token received: \(data)")
             case .failure(let error):
                 print("Error fetching OAuth token: \(error)")
                 // Handle error
             }
         }
         
    }
}


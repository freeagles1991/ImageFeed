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
    
    func decodeTokenResponse(with jsonString: String){
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                let authResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: jsonData)
                print(authResponse)
            } catch {
                print("Error decoding JSON: \(error)")
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
        
        func fetchOAuthToken(code: String){
            guard let request = makeOAuthTokenRequest(code: code) else {
                print("Invalid request")
                return }
            let task = URLSession.shared.dataTask(with: request)
            task.resume()
        }
        
    }
}

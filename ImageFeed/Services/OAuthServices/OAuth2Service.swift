//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Дима on 08.06.2024.
//

import Foundation
import SwiftKeychainWrapper
    
final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
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
              print("OAuth2Service.fetchOAuthToken: сессия прервана")
              return
          }
          
          let task = URLSession.shared.objectTask(for: request) { (result: Result<OAuthTokenResponseBody, Error>) in
              switch result {
              case .success(let responseBody):
                  let token = responseBody.accessToken
                  let isSuccess = KeychainWrapper.standard.set(token, forKey: "Auth token")
                  guard isSuccess else {
                      print("OAuth2Service.fetchOAuthToken: токен не записан в KeyChain")
                            return
                  }

                  DispatchQueue.main.async {
                      completion(.success(token))
                  }
                  print("OAuth2Service.fetchOAuthToken: OAuth токен получен: \(token)")
              case .failure(let error):
                  DispatchQueue.main.async {
                      completion(.failure(error))
                  }
                  switch error {
                  case NetworkError.httpStatusCode(let statusCode):
                      print("OAuth2Service.fetchOAuthToken. HTTP Error: status-code \(statusCode)")
                  case NetworkError.urlRequestError(let requestError):
                      print("OAuth2Service.fetchOAuthToken. Request error: \(requestError.localizedDescription)")
                  case NetworkError.urlSessionError:
                      print("OAuth2Service.fetchOAuthToken. URLSession Error")
                  default:
                      print("OAuth2Service.fetchOAuthToken. Unknown error: \(error.localizedDescription)")
                  }
                  print("OAuth2Service.fetchOAuthToken. Ошибка при декодировании токена")
              }
              self.task = nil
              self.lastCode = nil
          }
        self.task = task
        task.resume()
    }
    
    func getToken() -> String?{
        let token: String? = KeychainWrapper.standard.string(forKey: "Auth token")
        return token
    }
}



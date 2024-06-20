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
        
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                let decodeResult = ProfileResultResponseBody.decodeProfileResponse(from: data)
                switch decodeResult {
                case .success(let profileResult):
                    let profile = profileResult.toProfile()
                    print(profile)
                    DispatchQueue.main.async {
                        completion(.success(profile))
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
    
    func saveDataToFile(data: Data, fileName: String) {
        let fileManager = FileManager.default
        do {
            // Получаем URL для сохранения файла в директории документов
            let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentsURL.appendingPathComponent(fileName)
            
            // Записываем данные в файл
            try data.write(to: fileURL)
            print("Data saved to file: \(fileURL.path)")
        } catch {
            print("Failed to save data to file: \(error.localizedDescription)")
        }
    }
}

//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Дима on 28.06.2024.
//

import Foundation

final class ImagesListService{
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    
    private var task: URLSessionTask?
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private func makePhotosRequest(_ page: Int) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            print("Invalid base URL")
            return nil
        }
        
        guard let url = URL(
            string: "/photos"
            + "?page=\(page)",
            relativeTo: baseURL
        ) else {
            print("Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if task != nil{
            completion(.failure(NetworkError.urlSessionError))
            print("ImagesListService.fetchPhotosNextPage: запрос уже выполняется")
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let request = makePhotosRequest(nextPage) else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.urlSessionError))
            }
            print("ImagesListService.fetchPhotosNextPage: сессия прервана")
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) {(result: Result<[PhotoResultBody], Error>) in
            switch result {
            case .success(let photosResult):
                var newPhotos: [Photo] = []
                for photoResult in photosResult{
                    guard let photo = photoResult.convertToPhoto() else { return }
                    newPhotos.append(photo)
                }
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    completion(.success(newPhotos))
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                            object: self,
                            userInfo: ["Photos": newPhotos])
                }
                print("ImagesListService.fetchPhotosNextPage: Фото загружены")
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                switch error {
                case NetworkError.httpStatusCode(let statusCode):
                    print("ImagesListService.fetchPhotosNextPage. HTTP Error: status-code \(statusCode)")
                case NetworkError.urlRequestError(let requestError):
                    print("ImagesListService.fetchPhotosNextPage. Request error: \(requestError.localizedDescription)")
                case NetworkError.urlSessionError:
                    print("ImagesListService.fetchPhotosNextPage. URLSession Error")
                default:
                    print("ImagesListService.fetchPhotosNextPage. Unknown error: \(error.localizedDescription)")
                }
                print("ImagesListService.fetchPhotosNextPage. Ошибка при декодировании токена")
            }
            self.task = nil
        }
      self.task = task
      task.resume()
    }
}
    


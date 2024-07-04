//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Дима on 28.06.2024.
//

import Foundation

final class ImagesListService{
    static let shared = ImagesListService()
    private init() {}
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    
    let oauthService = OAuth2Service.shared
    private var task: URLSessionTask?
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private func makePhotosRequest(_ page: Int) -> URLRequest? {
        guard let baseURL = URL(string: "https://api.unsplash.com") else {
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
        request.httpMethod = "GET"
        guard let token = oauthService.getToken()
        else {
            print("No token")
            return nil}
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
         assert(Thread.isMainThread)

         if task != nil {
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

         task = URLSession.shared.objectTask(for: request) { (result: Result<[PhotoResultBody], Error>) in
             switch result {
             case .success(let photosResult):
                 var newPhotos: [Photo] = []
                 for photoResult in photosResult {
                     guard let photo = photoResult.convertToPhoto() else {
                         DispatchQueue.main.async {
                             print("ImagesListService.fetchPhotosNextPage: ошибка декодирования")
                             completion(.failure(NetworkError.urlSessionError))
                         }
                         return
                     }
                     newPhotos.append(photo)
                 }
                 DispatchQueue.main.async {
                     self.lastLoadedPage = nextPage
                     self.photos.append(contentsOf: newPhotos)
                     completion(.success(newPhotos))
                     NotificationCenter.default.post(
                         name: ImagesListService.didChangeNotification,
                         object: self,
                         userInfo: ["Photos": newPhotos]
                     )
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
             }
             self.task = nil
         }
         task?.resume()
     }
    
    private func makeChangeLikeRequest(photoID: String, isLike: Bool) -> URLRequest? {
        guard let baseURL = URL(string: "https://api.unsplash.com") else {
            print("Invalid base URL")
            return nil
        }
        
        guard let url = URL(
            string: "/photos/\(photoID)/like",
            relativeTo: baseURL
        ) else {
            print("Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "DELETE" : "POST"
        guard let token = oauthService.getToken()
        else {
            print("No token")
            return nil}
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void){
        assert(Thread.isMainThread)
        
        if task != nil {
            completion(.failure(NetworkError.urlSessionError))
            print("ImagesListService.changeLike: запрос уже выполняется")
            return
        }
        
        guard let request = makeChangeLikeRequest(photoID: photoId, isLike: isLike) else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.urlSessionError))
            }
            print("ImagesListService.changeLike: сессия прервана")
            return
        }
        
        task = URLSession.shared.objectTask(for: request) { (result: Result<LikeResponseBody, Error>) in
            switch result {
            case .success(let response):
                guard let likedPhoto = response.photo.convertToPhoto() else {
                    DispatchQueue.main.async {
                        print("ImagesListService.changeLike: ошибка декодирования")
                        completion(.failure(NetworkError.urlSessionError))
                    }
                    return
                }
                DispatchQueue.main.async {
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        let photo = self.photos[index]
                        let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: !photo.isLiked
                        )
                        guard let withReplaced = self.photos.withReplaced(itemAt: index, newValue: newPhoto) else { return }
                            self.photos = withReplaced
                        completion(.success(()))
                        NotificationCenter.default.post(
                            name: ImagesListService.didChangeNotification,
                            object: self,
                            userInfo: [:]
                        )
                        print("ImagesListService.changeLike: Лайк изменен")
                    }
                    else {
                        completion(.failure(NetworkError.urlSessionError))
                        print("ImagesListService.changeLike: Лайк не изменен, индекс фото некорректный")
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                switch error {
                case NetworkError.httpStatusCode(let statusCode):
                    print("ImagesListService.changeLike. HTTP Error: status-code \(statusCode)")
                case NetworkError.urlRequestError(let requestError):
                    print("ImagesListService.changeLike. Request error: \(requestError.localizedDescription)")
                case NetworkError.urlSessionError:
                    print("ImagesListService.changeLike. URLSession Error")
                default:
                    print("ImagesListService.changeLike. Unknown error: \(error.localizedDescription)")
                }
            }
            self.task = nil
        }
        task?.resume()
    }
}
    


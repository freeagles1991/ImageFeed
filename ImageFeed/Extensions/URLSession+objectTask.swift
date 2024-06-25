//
//  URLSession+objectTask.swift
//  ImageFeed
//
//  Created by Дима on 25.06.2024.
//

import Foundation

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result{
            case .success(let data):
                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                        completion(.success(decodedObject))
                    } catch {
                        completion(.failure(error))
                    }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
}

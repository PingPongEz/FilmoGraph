//
//  NetworkTest.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 14/06/2022.
//

import Foundation
import UIKit

class ImageLoader {
    
    private var loadedImages = [URL: UIImage]()
    private var runningRequests = [UUID: URLSessionDataTask]()
    
    func loadImage(_ url: URL, _ completion: @escaping(Result<UIImage, Error>) -> Void) -> UUID? {
        
//        if let image = loadedImages[url] {
//            completion(.success(image))
//            print("Loaded")
//            return nil
//        }
        
        if let cacheImage = Cache.getCachedImage(from: url) {
            completion(.success(cacheImage))
            print("GET")
            return nil
        }
        
        let uuid = UUID()
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            print(url)
//            defer { self.runningRequests.removeValue(forKey: uuid) }
            
            if let data = data, let image = UIImage(data: data), let response = response {
                Cache.cacheImage(with: data, response)
                completion(.success(image))
                return
            }
            
            guard let error = error else { return }

            guard (error as NSError).code == NSURLErrorCancelled else {
                completion(.failure(error))
                return
            }
        }
        task.resume()
        
        runningRequests[uuid] = task
        return uuid
    }
    
    func cancelLoad(_ uuid: UUID) {
        runningRequests[uuid]?.cancel()
        runningRequests.removeValue(forKey: uuid)
    }
}

struct FetchSomeFilm {
    
    static var shared = FetchSomeFilm()
    private init(){}

    
    func fetch(completion: @escaping(Result<Welcome, Error>) -> Void) {
        guard let url = URL(string: "https://api.rawg.io/api/games?key=7f01c67ed4d2433bb82f3dd38282088c&page_size=20") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.allHTTPHeaderFields = [
            "application/json" : "Content-Type",
            "page_size" : "1"
        ]
        
        let task = URLSession.shared.dataTask(with: request) { data, responce, error in
            guard let data = data else { return }
            
            do {
                let formatter = DateFormatter()
                var decoder: JSONDecoder {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    decoder.dateDecodingStrategy = .custom({ decoder -> Date in
                        let container = try decoder.singleValueContainer()
                        let dateString = try container.decode(String.self)
                        
                        formatter.dateFormat = "yyyy-MM-dd"
                        if let date = formatter.date(from: dateString) {
                            return date
                        }
                        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                        if let date = formatter.date(from: dateString) {
                            return date
                        }
                        throw DecodingError.dataCorruptedError(in: container, debugDescription: ":(")
                    })
                    return decoder
                }
                let welcome = try decoder.decode(Welcome.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(welcome))
                }
                
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
}

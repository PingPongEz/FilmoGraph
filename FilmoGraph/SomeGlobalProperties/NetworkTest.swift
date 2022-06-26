//
//  NetworkTest.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 14/06/2022.
//

import Foundation
import UIKit


class ImageLoader {
        func loadImage(_ url: URL, _ completion: @escaping(Result<UIImage, Error>) -> Void) -> UUID? {
        if let cacheImage = Cached.shared.loadedImages.object(forKey: url.absoluteString as NSString) {
            completion(.success(cacheImage))
            return UUID()
        }
        
        let uuid = UUID()
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let data = data, let image = UIImage(data: data) {
                Cached.shared.loadedImages.setObject(image, forKey: url.absoluteString as NSString)
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
        
        URLResquests.shared.runningRequests[uuid] = task
        return uuid
    }
    
    func cancelLoad(_ uuid: UUID) {
        URLResquests.shared.runningRequests[uuid]?.cancel()
        URLResquests.shared.runningRequests.removeValue(forKey: uuid)
    }
}

class FetchSomeFilm {
    
    static var shared = FetchSomeFilm()
    private init(){}
    
    var formatter = DateFormatter()
    
    func findSomeGames(with text: String, completion: @escaping(Result<Welcome, Error>) -> Void) -> UUID {
        guard let url = URL(string: "https://api.rawg.io/api/games?key=7f01c67ed4d2433bb82f3dd38282088c&page_size=20&page=1&search=\(text)") else { return UUID() }
        print(url)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.allHTTPHeaderFields = [
            "application/json" : "Content-Type",
//            "page_size" : "1"
        ]
        
        let uuid = UUID()
        let task = URLSession.shared.dataTask(with: request) { [unowned self] data, response, error in
            guard let data = data else { return }
            
            do {
                let welcome = try decoder.decode(Welcome.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(welcome))
                }
            } catch let DecodingError.dataCorrupted(context) {
                print(context)
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.typeMismatch(type, context)  {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch {
                print("error: ", error)
            }
        }
        task.resume()
        URLResquests.shared.runningRequests[uuid] = task
        return uuid
    }
    
    func cancelLoadAtUUID(uuid: UUID) {
        URLResquests.shared.runningRequests[uuid]?.cancel()
        URLResquests.shared.runningRequests.removeValue(forKey: uuid)
    }
    
    func fetchWith(page: Int? = nil, orUrl url: String? = nil, completion: @escaping(Result<Welcome, Error>) -> Void) -> UUID {
        var urlForFetch: String?
        
        if let url = url {
            urlForFetch = url
        } else {
            guard let page = page else { return UUID() }
            urlForFetch = "https://api.rawg.io/api/games?key=7f01c67ed4d2433bb82f3dd38282088c&page=\(page)&page_size=20"
        }
        
        guard let urlForFetch = URL(string: urlForFetch ?? "") else { return UUID() }
        let uuid = UUID()
        
        var request = URLRequest(url: urlForFetch)
        request.httpMethod = "GET"
        
        request.allHTTPHeaderFields = [
            "application/json" : "Content-Type"
        ]
        
        let task = URLSession.shared.dataTask(with: request) { [unowned self] data, responce, error in
            guard let data = data else { return }
            
            do {
                let welcome = try decoder.decode(Welcome.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(welcome))
                }
                
            } catch let DecodingError.dataCorrupted(context) {
                print(context)
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.typeMismatch(type, context)  {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch {
                print("error: ", error)
            }
        }
        URLResquests.shared.runningRequests[uuid] = task
        task.resume()
        return uuid
    }
    
    
    func fetchGameDetails(with url: String, completion: @escaping(Result<GameDetais, Error>) -> Void) {
        guard let url = URL(string: url) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = [ "application/json" : "Content-Type", "page_size" : "1" ]
        
        URLSession.shared.dataTask(with: request) { [unowned self] data, _, error in
            guard let data = data else { completion(.failure(error!)); return }
            print(url.absoluteString)
            do {
                let gameDetails = try decoder.decode(GameDetais.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(gameDetails))
                }
            } catch let DecodingError.dataCorrupted(context) {
                print(context)
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.typeMismatch(type, context)  {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch {
                print("error: ", error)
            }
        }.resume()
    }
}

//MARK: Decoder
extension FetchSomeFilm {
    
    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom({ [unowned self] decoder -> Date in
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
}

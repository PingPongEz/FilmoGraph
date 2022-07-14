//
//  NetworkTest.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 14/06/2022.
//

import Foundation
import UIKit
import Alamofire




//MARK: ImageLoader
final class ImageLoader {
    
    private init(){}
    static var shared = ImageLoader()
    
    func loadImage(_ url: URL, _ completion: @escaping(Result<UIImage, Error>) -> Void) -> UUID? {
        
        if let cacheImage = Cache.shared.getFromCache(with: NSString(string: url.absoluteString)) {
            completion(.success(cacheImage))
            return UUID()
        }
        
        let uuid = UUID()
        
        let header = HTTPHeaders([ "application/json" : "Content-Type" ])
        let task = AF.request(url, headers: header)
            .validate()
            .response(queue: GlobalQueueAndGroup.shared.queue) { response in
                switch response.result {
                case .success(let data):
                    guard let data = data else { return }
                    
                    Cache.shared.saveToCache(with: NSString(string: url.absoluteString), and: data)
                    guard let image = UIImage(data: data) else { return }
                    completion(.success(image))
                case .failure(let error):
                    print("error in single image")
                    completion(.failure(error))
                }
            }
        
        task.resume()
        URLResquests.shared.addTasksToArray(uuid: uuid, task: task)
        return uuid
    }
    
    func cancelLoad(uuid: UUID?) {
        URLResquests.shared.deleteOneRequest(request: uuid)
    }
}


final class FetchSomeFilm {
    
    static let shared = FetchSomeFilm()
    private init(){}
    
    
    private let formatter = DateFormatter()
    private let header = HTTPHeaders([ "application/json" : "Content-Type" ])
    private let interseptor = Interceptor()
    
    //MARK: Scrennshots
    func fetchScreenShots(with url: String, completion: @escaping(ScreenShots) -> Void) -> UUID? {
        
        let trueURL = "https://api.rawg.io/api/games/\(url)/screenshots?key=7f01c67ed4d2433bb82f3dd38282088c"
        
        let uuid = UUID()
        
        let task = AF.request(trueURL, headers: header)
            .validate()
            .response(queue: GlobalQueueAndGroup.shared.queue) { [unowned self] response in
                switch response.result {
                case .success(let data):
                    guard let data = data else { return }
                    guard let screens: ScreenShots = doCatch(from: data) else { return }
                    DispatchQueue.main.async {
                        completion(screens)
                    }
                case .failure(let error):
                    print("error in screenshots")
                    print(error)
                }
            }
        
        task.resume()
        URLResquests.shared.addTasksToArray(uuid: uuid, task: task)
        return uuid
    }
    
    //MARK: Games
    func fetchWith(page: Int? = nil, orUrl url: String? = nil, ordering: String, isReversed: Bool, completion: @escaping(Welcome) -> Void) -> UUID? {
        
        var urlForFetch = ""
        var kingOfSort = ""
        
        isReversed ? (kingOfSort = "-\(ordering)") : (kingOfSort = ordering)
        
        if let page = page {
            urlForFetch = "https://api.rawg.io/api/games?key=7f01c67ed4d2433bb82f3dd38282088c&page=\(page)&page_size=20&ordering=\(kingOfSort)"
            print(urlForFetch)
        } else {
            guard let url = url else { return UUID() }
            urlForFetch = url
        }
        
        let uuid = UUID()
        
        let task = AF.request(urlForFetch, headers: header)
            .validate()
            .response(queue: GlobalQueueAndGroup.shared.queue) { [ unowned self ] response in
                switch response.result {
                case .success(let data):
                    guard let data = data else { return }
                    guard let result: Welcome = doCatch(from: data) else { return }
                    DispatchQueue.main.async {
                        completion(result)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        
        
        task.resume()
        URLResquests.shared.addTasksToArray(uuid: uuid, task: task)
        return uuid
    }
    
    //MARK: Search fetch
    func searchFetch(onPage page: Int, with text: String? = nil, ganre: Int? = nil, platform: Int? = nil, completion: @escaping(Welcome) -> Void) -> UUID? {
        
        let uuid = UUID()
        var urlConstructor = "https://api.rawg.io/api/games?key=7f01c67ed4d2433bb82f3dd38282088c&page_size=20&page=\(page)"
        
        if let text = text { urlConstructor += "&search=\(text)" }
        if let ganre = ganre { urlConstructor += "&genres=\(ganre)" }
        if let platform = platform { urlConstructor += "&platforms=\(platform)" }
        
        let task = AF.request(urlConstructor, headers: header)
            .validate()
            .response(queue: GlobalQueueAndGroup.shared.queue) { [unowned self] response in
                switch response.result {
                case .success(let data):
                    guard let data = data else { return }
                    guard let result: Welcome = doCatch(from: data) else { return }
                    DispatchQueue.main.async {
                        completion(result)
                    }
                case .failure(let error):
                    print("error in searchFetch")
                    print(error)
                }
            }
        
        task.resume()
        URLResquests.shared.addTasksToArray(uuid: uuid, task: task)
        return uuid
    }
    
    
    //MARK: Game details
    func fetchGameDetails(with url: String, completion: @escaping(GameDetais) -> Void) -> UUID? {
        
        let uuid = UUID()
        
        let task = AF.request(url, headers: header)
            .validate()
            .response(queue: GlobalQueueAndGroup.shared.queue) { [unowned self] response in
                switch response.result {
                case .success(let data):
                    guard let data = data else { return }
                    guard let details: GameDetais = doCatch(from: data) else { return }
                    DispatchQueue.main.async {
                        completion(details)
                    }
                case .failure(let error):
                    print("error in Details")
                    print(error)
                }
            }
        
        task.resume()
        URLResquests.shared.addTasksToArray(uuid: uuid, task: task)
        return uuid
    }
    
    //MARK: Fetch Genres
    func fetchGenres(completion: @escaping (Genres) -> ()) {
        let url = "https://api.rawg.io/api/genres?key=7f01c67ed4d2433bb82f3dd38282088c"
        
        AF.request(url, headers: header)
            .validate()
            .response(queue: GlobalQueueAndGroup.shared.queue) { [unowned self] response in
                switch response.result {
                case .success(let data):
                    guard let data = data else { return }
                    guard let genres: Genres = doCatch(from: data) else { return }
                    completion(genres)
                case .failure(let error):
                    print(error)
                }
            }.resume()
    }
    
    
    //MARK: Fetch Platforms
    func fetchAllPlatforms(with url: String, completion: @escaping () -> ()) {
        
        AF.request(url, headers: header)
            .validate()
            .response(queue: GlobalQueueAndGroup.shared.queue) { [unowned self] response in
                switch response.result {
                case .success(let data):
                    guard let data = data else { return }
                    
                    guard let platforms: AllPlatforms? = doCatch(from: data) else { return }
                    GlobalProperties.shared.platforms.value += platforms?.results ?? []
                    
                    if let next = platforms?.next {
                        fetchAllPlatforms(with: next) { }
                    }
                    
                    completion()
                    
                case .failure(let error):
                    print(error)
                }
            }.resume()
    }
}



//MARK: Decoder
extension FetchSomeFilm {
    
    
    private func doCatch<T: Codable>(from data: Data) -> T? {
        var type: T?
        do {
            type = try decoder.decode(T.self, from: data)
            return type
        } catch {
            print(error)
        }
        return type
    }
    
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

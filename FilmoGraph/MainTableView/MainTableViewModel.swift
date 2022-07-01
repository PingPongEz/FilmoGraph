//
//  MainTableViewModel.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 14/06/2022.
//

import Foundation
import UIKit


final class MainTableViewModel : MainTableViewModelProtocol {
    
    var games: Observable<[Game]> = Observable([])
    
    var currentPage: Int = 1 {
        didSet {
            if currentPage < 1 {
                currentPage = 1
                print(URLResquests.shared.runningRequests.count)
            }
        }
    }
    
    var searchText: String = "" {
        didSet {
            searchText = searchText.replacingOccurrences(of: " ", with: "")
        }
    }
    
    var nextPage: String?
    var prevPage: String?
    var isShowAvailable = true
    
    private var currentRequest: UUID?
    private var listOfRequests = [UUID?]()
    private var screenShots: [ScreenShotsResult]?
    private var images = [UIImage]()
    
    
    func fetchGamesWith(page: Int? = nil, orUrl url: String? = nil, completion: @escaping () -> Void) {
        DispatchQueue.global().async { [unowned self] in
            currentRequest = FetchSomeFilm.shared.fetchWith(page: page, orUrl: url, search: searchText) {  result in
                switch result {
                case .success(let result):
                    DispatchQueue.main.async {
                        self.nextPage = result.next
                        self.prevPage = result.previous
                        self.games = Observable(result.results)
                        self.stopRequest()
                        completion()
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func cellForRowAt(_ indexPath: IndexPath) -> CellViewModelProtocol {
        let game = games.value[indexPath.row]
        
        return CellViewModel(game: game)
    }
    
    func cellDidTap(_ indexPath: IndexPath) -> String {
        guard let string = games.value[indexPath.row].id else { return "" }
        return String("https://api.rawg.io/api/games/\(string)?key=7f01c67ed4d2433bb82f3dd38282088c")
    }
    
    func createDetailViewControllerModel(with urlForFetch: String?, completion: @escaping(GameDetais?) -> Void) {
        isShowAvailable = false
        guard let urlForFetch = urlForFetch else { return }
        GlobalGroup.shared.group.notify(queue: .global()) {
            FetchSomeFilm.shared.fetchGameDetails(with: urlForFetch) { result in
                do {
                    let details = try result.get()
                    DispatchQueue.main.async {
                        completion(details)
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func fetchScreenShots(gameSlug: String, completion: @escaping([UIImage]) -> Void) {
        DispatchQueue.global().async { [unowned self] in
            let request = FetchSomeFilm.shared.fetchScreenShots(with: gameSlug) { result in
                do {
                    let images = try result.get()
                    DispatchQueue.main.async {
                        self.screenShots = images.results
                        self.unpackScreenshots { images in
                            completion(images)
                        }
                    }
                } catch {
                    print(error)
                }
            }
            listOfRequests.append(request)
        }
    }
    
    private func unpackScreenshots(completion: @escaping ([UIImage]) -> Void) {
        DispatchQueue.global().async { [unowned self] in
            screenShots?.forEach { url in
                guard let url = URL(string: url.image ?? "") else { return }
                let request = ImageLoader.shared.loadImage(url) { result in  //MARK: Make delete from requests with protocol
                    do {
                        let image = try result.get()
                        DispatchQueue.main.async {
                            self.images.append(image)
                            if self.images.count == self.screenShots?.count {  //MARK: For only one completion call
                                completion(self.images)
                                self.images = []
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
                listOfRequests.append(request)
            }
        }
    }
    
    func deleteRequests() {
        URLResquests.shared.cancelRequests(requests: listOfRequests)
    }
    
    func stopRequest() {
        URLResquests.shared.deleteOneRequest(request: self.currentRequest)
    }
}


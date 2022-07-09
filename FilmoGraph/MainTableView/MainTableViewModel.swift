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
    var listOfRequests = [UUID?]()
    
    private var currentRequest: UUID?
    private var screenShots: [ScreenShotsResult]?
    
    func fetchGamesWith(page: Int? = nil, orUrl url: String? = nil, completion: @escaping () -> Void) {
        deleteOneRequest()
        DispatchQueue.global().async {
            self.currentRequest = FetchSomeFilm.shared.fetchWith(page: page, orUrl: url, search: self.searchText) {  result in
                switch result {
                case .success(let result):
                    DispatchQueue.main.async {
                        self.nextPage = result.next
                        self.prevPage = result.previous
                        self.games = Observable(result.results)
                        self.deleteOneRequest()
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
    
    func downloadEveryThingForDetails(with indexPath: IndexPath) -> DetailGameViewController {
        let url = cellDidTap(indexPath)
        let detailVC = DetailGameViewController()
        
        let concurrentQueue = DispatchQueue(label: "Loading details", qos: .utility, attributes: .concurrent)
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        concurrentQueue.async(group: dispatchGroup) { [unowned self] in
            createDetailViewControllerModel(with: url) { details in
                detailVC.viewModel = DetailGameViewModel(game: details)
                
                Mutex.shared.available = true
                pthread_cond_signal(&Mutex.shared.condition)
                
                dispatchGroup.leave()
            }
        }
        
        
        dispatchGroup.enter()
        concurrentQueue.async(group: dispatchGroup) { [unowned self] in
            
            guard let slug = games.value[indexPath.row].slug else { return }
            fetchScreenShots(gameSlug: slug) { images in
                LockMutex {
                    detailVC.viewModel?.images = images
                    self.deleteRequests()
                    dispatchGroup.leave()
                }.start()
            }
            
        }
        
        dispatchGroup.notify(queue: .main) {
            detailVC.uploadUI()
        }
        
        return detailVC
    }
    
    private func cellDidTap(_ indexPath: IndexPath) -> String {
        guard let string = games.value[indexPath.row].id else { return "" }
        return String("https://api.rawg.io/api/games/\(string)?key=7f01c67ed4d2433bb82f3dd38282088c")
    }
    
    private func createDetailViewControllerModel(with urlForFetch: String?, completion: @escaping(GameDetais?) -> Void) {
        isShowAvailable = false
        
        guard let urlForFetch = urlForFetch else { return }
        GlobalGroup.shared.group.notify(queue: .global()) { [unowned self ] in
            
            let request = FetchSomeFilm.shared.fetchGameDetails(with: urlForFetch) { result in
                do {
                    let details = try result.get()
                    DispatchQueue.main.async {
                        completion(details)
                    }
                } catch {
                    print(error)
                }
            }
            self.listOfRequests.append(request)
        }
    }
    
    private func fetchScreenShots(gameSlug: String, completion: @escaping([UIImage]) -> Void) {
        
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
            self.listOfRequests.append(request)
        }
    }
    
    private func unpackScreenshots(completion: @escaping ([UIImage]) -> Void) {
        var loadedImages = [UIImage]()
        
        DispatchQueue.global().async { [unowned self] in
            
            screenShots?.forEach { url in
                guard let url = URL(string: url.image ?? "") else { return }
                let request = ImageLoader.shared.loadImage(url) { result in
                    do {
                        let image = try result.get()
                        DispatchQueue.main.async {
                            loadedImages.append(image)
                            if loadedImages.count == self.screenShots?.count {  //MARK: For only one completion call
                                completion(loadedImages)
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
                self.listOfRequests.append(request)
            }
        }
    }
    
    func deleteRequests() {
        URLResquests.shared.cancelRequests(requests: listOfRequests)
        listOfRequests.removeAll()
    }
    
    func deleteOneRequest() {
        URLResquests.shared.deleteOneRequest(request: self.currentRequest)
    }
}


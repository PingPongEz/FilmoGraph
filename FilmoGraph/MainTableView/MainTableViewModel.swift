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
        self.currentRequest = FetchSomeFilm.shared.fetchWith(page: page, orUrl: self.searchText) {  result in
            self.nextPage = result.next
            self.prevPage = result.previous
            self.games = Observable(result.results)
            self.deleteOneRequest()
            DispatchQueue.main.async {
                completion()
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
        
        let concurrentQueue = GlobalQueueAndGroup.shared.queue
        let dispatchGroup = GlobalQueueAndGroup.shared.group
        
        concurrentQueue.async(group: dispatchGroup) { [unowned self] in
            dispatchGroup.enter()
            createDetailViewControllerModel(with: url) { details in
                detailVC.viewModel = DetailGameViewModel(game: details)
                
                Mutex.shared.available = true
                pthread_cond_signal(&Mutex.shared.condition)
                
                dispatchGroup.leave()
            }
        }
        
        
        concurrentQueue.async(group: dispatchGroup) { [unowned self] in
            
            dispatchGroup.enter()
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
        let request = FetchSomeFilm.shared.fetchGameDetails(with: urlForFetch) { result in
            completion(result)
            self.listOfRequests.append(request)
        }
    }
    
    private func fetchScreenShots(gameSlug: String, completion: @escaping([UIImage]) -> Void) {
        
        let request = FetchSomeFilm.shared.fetchScreenShots(with: gameSlug) { result in
            self.screenShots = result.results
            self.unpackScreenshots { images in
                completion(images)
            }
        }
        self.listOfRequests.append(request)
    }
    
    private func unpackScreenshots(completion: @escaping ([UIImage]) -> Void) {
        var loadedImages = [UIImage]()
        
        screenShots?.forEach { url in
            guard let url = URL(string: url.image ?? "") else { return }
            let request = ImageLoader.shared.loadImage(url) { result in
                loadedImages.append(result)
                DispatchQueue.main.async {
                    if loadedImages.count == self.screenShots?.count {  //MARK: For only one completion call
                        completion(loadedImages)
                    }
                }
            }
            self.listOfRequests.append(request)
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


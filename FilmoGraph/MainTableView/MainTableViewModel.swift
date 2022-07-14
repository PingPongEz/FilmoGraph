//
//  MainTableViewModel.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 14/06/2022.
//

import Foundation
import UIKit


final class MainTableViewModel: MainTableViewModelProtocol {
    
    var games: Observable<[Game]> = Observable([])
    
    var currentPage: Int = 1 {
        didSet {
            if currentPage < 1 {
                currentPage = 1
            }
        }
    }

    var nextPage: String?
    var prevPage: String?
    var isShowAvailable = true
    var listOfRequests = [UUID?]()
    
    private let concurrentQueue = GlobalQueueAndGroup.shared.queue
    private let dispatchGroup = GlobalQueueAndGroup.shared.group
    
    private var currentRequest: UUID?
    private var screenShots: [ScreenShotsResult]?
    
    private let semaphoreForImages = DispatchSemaphore(value: 1)
    private let semaphoreForRequests = DispatchSemaphore(value: 1)
    
    private var loadedImages = [UIImage]()
        
    private func appendRequest(_ uuid: UUID?) { // Safe append
        semaphoreForRequests.wait()
        listOfRequests.append(uuid)
        semaphoreForRequests.signal()
    }
    
    private func appendImage(_ image: UIImage) { // Safe append
        semaphoreForImages.wait()
        loadedImages.append(image)
        semaphoreForImages.signal()
    }
    
    private func downLoadViewModelForDetails(with indexPath: IndexPath, completion: @escaping (GameDetais) -> Void) {
        
        let url = cellDidTap(indexPath)
        
        concurrentQueue.async(group: dispatchGroup) { [unowned self] in
            dispatchGroup.enter()
            createDetailViewControllerModel(with: url) { details in
                
                completion(details)
                
                Mutex.shared.available = true
                pthread_cond_signal(&Mutex.shared.condition)
                print(Mutex.shared.available)
                
                self.dispatchGroup.leave()
            }
        }
    }
    
    private func downloadScreenShots(with indexPath: IndexPath, completion: @escaping([UIImage]) -> Void) {
        
        concurrentQueue.async(group: dispatchGroup) { [unowned self] in
            
            dispatchGroup.enter()
            guard let slug = games.value[indexPath.row].slug else { return }
            fetchScreenShots(gameSlug: slug) { images in
                LockMutex {
                    completion(images)
                    
                    self.deleteRequests()
                    self.dispatchGroup.leave()
                }.start()
            }
        }
    }
    
    private func cellDidTap(_ indexPath: IndexPath) -> String {
        guard let string = games.value[indexPath.row].id else { return "" }
        return String("https://api.rawg.io/api/games/\(string)?key=7f01c67ed4d2433bb82f3dd38282088c")
    }
    
    private func createDetailViewControllerModel(with urlForFetch: String?, completion: @escaping(GameDetais) -> Void) {
        isShowAvailable = false
        
        guard let urlForFetch = urlForFetch else { return }
        let request = FetchSomeFilm.shared.fetchGameDetails(with: urlForFetch) { result in
            completion(result)
        }
        appendRequest(request)
    }
    
    private func fetchScreenShots(gameSlug: String, completion: @escaping([UIImage]) -> Void) {
        
        let request = FetchSomeFilm.shared.fetchScreenShots(with: gameSlug) { result in
            self.screenShots = result.results
            self.unpackScreenshots { images in
                completion(images)
            }
        }
        appendRequest(request)
    }
    
    private func unpackScreenshots(completion: @escaping ([UIImage]) -> Void) {
        screenShots?.forEach { url in
            guard let url = URL(string: url.image ?? "") else { return }
            
            let request = ImageLoader.shared.loadImage(url) { [unowned self] result in
                
                switch result {
                case .success(let resultImage):
                    appendImage(resultImage)
                    if loadedImages.count == self.screenShots?.count {  //MARK: For only one completion call
                        completion(loadedImages)
                        loadedImages = []
                    }
                case .failure(let error):
                    print(error)
                }
                
            }
            appendRequest(request)
        }
    }
    
    func fetchGamesWith(page: Int? = nil, completion: @escaping () -> Void) {
        deleteOneRequest()
        self.currentRequest = FetchSomeFilm.shared.fetchWith(page: page) { result in
            self.nextPage = result.next
            self.prevPage = result.previous
            self.games = Observable(result.results)
            self.deleteOneRequest()
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func cellForRowAt(_ indexPath: IndexPath)-> CellViewModelProtocol {
        let game = games.value[indexPath.row]
        return CellViewModel(game: game)
    }
    
    
    func downloadEveryThingForDetails(with indexPath: IndexPath) -> DetailGameViewController {
        let detailVC = DetailGameViewController()
        
        downLoadViewModelForDetails(with: indexPath) { details in
            detailVC.viewModel = DetailGameViewModel(game: details)
        }
        
        downloadScreenShots(with: indexPath) { images in
            detailVC.viewModel?.images = images
        }
        
        dispatchGroup.notify(queue: .main) {
            detailVC.uploadUI()
        }
        
        return detailVC
    }
    
    func deleteRequests() {
        URLResquests.shared.cancelRequests(requests: listOfRequests)
        print(URLResquests.shared.runningRequests.count)
    }
    
    func deleteOneRequest() {
        URLResquests.shared.deleteOneRequest(request: self.currentRequest)
    }
}

#if DEBUG

extension MainTableViewModel {
    
}

#endif

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
    
    var currentPage: Int = 2                            //Setted to 2 because of view initing with fetch on page 1

    var isReversed: Observable<Bool> = Observable(true)
    
    var isReversedString: String {
        get {
            if isReversed.value {
                return "arrow.down.square"
            } else {
                return "arrow.up.square"
            }
        }
    }
    
    var ordering: SortGames = .added  //King of sorting
    var image: UIImage = UIImage(systemName: "arrow.down.square") ?? UIImage()
    
    var nextPage: String?
    var prevPage: String?
    var isShowAvailable = true
    var listOfRequests = [UUID?]()
    
    // **If searching works**
    var isSearchingViewController = false
    var currentGengre: Genre?
    var currentPlatform: Platform?
    var textForSearchFetch: String?
    
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
            
            let request = ImageLoader.shared.loadImageWithData(url) { [unowned self] result in
                
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
    
    private func updateAfterFetch(with result: Welcome, completion: @escaping () -> Void) {
        nextPage = result.next
        prevPage = result.previous
        games.value += result.results
        deleteOneRequest()
        
        DispatchQueue.main.async {
            completion()
        }
    }
    
    private func calculateItemsForReloadCollectionView(count: Int) -> [IndexPath] {
        var insertingItems: [IndexPath] = []
        
        print(count, currentPage)
        let start = (currentPage - 2) * count                               //Calculating range of items
        let end = (currentPage - 1) * count
        
        for item in (start..<end) {
            insertingItems.append(IndexPath(item: item, section: 0))
        }
        
        return insertingItems
    }
    
    func reverseSorting(startAction: @escaping () -> Void, completion: @escaping ([IndexPath]) -> Void) {
        
        isReversed.value.toggle()
        
        currentPage = 1             //Making it for delete old values
        games = Observable([])
        
        startAction()
        
        fetchGamesWith { [unowned self] items in
            completion(items)
        }
    }
    
    func createAlertController(startAction: @escaping() -> Void ,completion: @escaping ([IndexPath]) -> Void) -> UIAlertController {
        
        let actionSheet = UIAlertController(title: "Choose sorting", message: "Sort by:", preferredStyle: .actionSheet)
        
        SortGames.allCases.forEach { method in
            let action = UIAlertAction(title: method.rawValue.capitalized, style: .default) { [unowned self] _ in
                
                currentPage = 1         //Making it for delete old values
                
                startAction()
                games = Observable([])
                
                switch method {
                case .name:
                    ordering = .name
                case .released:
                    ordering = .released
                case .added:
                    ordering = .added
                case .created:
                    ordering = .created
                case .updated:
                    ordering = .updated
                case .rating:
                    ordering = .rating
                case .metacritic:
                    ordering = .metacritic
                }
                
                fetchGamesWith { items in
                    completion(items)
                }
            }
            actionSheet.addAction(action)
        }
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        return actionSheet
    }
    
    func fetchGamesWith(completion: @escaping ([IndexPath]) -> Void) {
        
        deleteOneRequest()
        
        self.currentRequest = FetchSomeFilm.shared.fetchWith(page: currentPage, ordering: ordering.rawValue, isReversed: isReversed.value) { [unowned self] result in
            
            currentPage += 1
            updateAfterFetch(with: result) {
                completion(self.calculateItemsForReloadCollectionView(count: result.results.count))
            }
            
        }
    }
    
    func searchFetch(completion: @escaping ([IndexPath]) -> Void) {
        
        deleteRequests()
        
        self.currentRequest = FetchSomeFilm.shared.searchFetch(onPage: currentPage, with: textForSearchFetch, ganre: currentGengre?.id, platform: currentPlatform?.id) { [unowned self] result in
            currentPage += 1
            
            updateAfterFetch(with: result) {
                completion(self.calculateItemsForReloadCollectionView(count: result.results.count))
            }
            
        }
    }
    
    func cellForRowAt(_ indexPath: IndexPath) -> CellViewModelProtocol {
        let game = games.value[indexPath.item]
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

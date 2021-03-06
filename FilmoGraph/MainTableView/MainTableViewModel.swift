//
//  MainTableViewModel.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 14/06/2022.
//

import Foundation
import UIKit


final class MainTableViewModel: MainTableViewModelProtocol {
    
    var games: Observable<[Any]> = Observable([])
    
    var currentPage: Int = 2                            //Setted to 2 because of view initing with fetch on page 1

    var isReversed: Observable<Bool> = Observable(true)
    
    var mainViewControllerState: MainViewControllerState = .games
    
    var ordering: SortGames = .added  //King of sorting
    
    var nextPage: String?
    var prevPage: String?
    var isShowAvailable = true
    var listOfRequests = [UUID?]()
    
    // **If searching works**
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
        
    //MARK: Reverse sort tapped
    func reverseSorting(startAction: @escaping () -> Void, completion: @escaping ([IndexPath]) -> Void) {
        
        isReversed.value.toggle()
        
        currentPage = 1             //Making it for delete old values
        games = Observable([])
        
        startAction()
        
        fetchGamesWith { items in
            completion(items)
        }
    }
    
    //MARK: Setting alertSheet buttons
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
    //MARK: Fetching games (non-search)
    func fetchGamesWith(completion: @escaping ([IndexPath]) -> Void) {
        
        deleteOneRequest()
        
        self.currentRequest = FetchSomeFilm.shared.fetchWith(page: currentPage, ordering: ordering.rawValue, isReversed: isReversed.value) { [unowned self] result in
            
            currentPage += 1
            updateAfterFetchGames(with: result) {
                completion(self.calculateItemsForReloadCollectionView(count: result.results.count))
            }
            
        }
    }
    
    //MARK: Fetching games (search)
    func searchFetch(completion: @escaping ([IndexPath]) -> Void) {
        
        deleteRequests()
        
        self.currentRequest = FetchSomeFilm.shared.searchFetch(onPage: currentPage, with: textForSearchFetch, ganre: currentGengre?.id, platform: currentPlatform?.id) { [unowned self] result in
            currentPage += 1
            
            updateAfterFetchGames(with: result) {
                completion(self.calculateItemsForReloadCollectionView(count: result.results.count))
            }
            
        }
    }
    
    //MARK: fetching publishers
    func fetchPublishers(completion: @escaping ([IndexPath]) -> Void) {
        self.currentRequest = FetchSomeFilm.shared.fetchPublishers(onPage: currentPage) { [unowned self] result in
            currentPage += 1
            
            updateAfterFetchPublishers(with: result) {
                completion(self.calculateItemsForReloadCollectionView(count: result.results.count))
            }
        }
    }
    
    //MARK: CellForRowAtIndexPath
    func cellForRowAt(_ indexPath: IndexPath) -> CellViewModelProtocol {
        
        switch mainViewControllerState {
        case .games:
            return CellViewModel(game: games.value[indexPath.item] as! Game)
        case .publishers:
            return CellViewModel(publisher: games.value[indexPath.item] as! Publisher)
        default:
            return CellViewModel(game: games.value[indexPath.item] as! Game)
        }
        
    }
    
    //MARK: Prepare for show detailsVC
    func downloadEveryThingForDetails(with indexPath: IndexPath) -> DetailGameViewController {
        let detailVC = DetailGameViewController()
        
        downLoadViewModelForDetails(with: indexPath) { details in
            detailVC.viewModel = DetailGameViewModel(game: details)
        }
        
        downloadScreenShots(with: indexPath) { images in
            detailVC.viewModel?.images = images
        }
        
        dispatchGroup.notify(queue: .main) {
            detailVC.uploadUI()                        //Setting detailsView UI before it's presented only after data ready for show
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
    
    //MARK: Fetch DetailsVC ViewModel
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
    
    
    //MARK: Setting fetch-string for details View Controller
    private func cellDidTap(_ indexPath: IndexPath) -> String {
        
        switch mainViewControllerState {
        case .games:
            let games = games.value as! [Game]
            guard let id = games[indexPath.item].id else { return "" }
            return String("https://api.rawg.io/api/games/\(id)?key=7f01c67ed4d2433bb82f3dd38282088c")
        case .publishers:
            let publishers = games.value as! [Publisher]
            guard let id = publishers[indexPath.item].id else { return "" }
            return String("https://api.rawg.io/api/games/\(id)?key=7f01c67ed4d2433bb82f3dd38282088c")
        default:
            let games = games.value as! [Game]
            guard let id = games[indexPath.item].id else { return "" }
            return String("https://api.rawg.io/api/games/\(id)?key=7f01c67ed4d2433bb82f3dd38282088c")
        }
    }
    
    //MARK: Creating detail View Controller
    private func createDetailViewControllerModel(with urlForFetch: String?, completion: @escaping(GameDetais) -> Void) {
        isShowAvailable = false
        
        guard let urlForFetch = urlForFetch else { return }
        let request = FetchSomeFilm.shared.fetchGameDetails(with: urlForFetch) { result in
            completion(result)
        }
        appendRequest(request)
    }
    
    //MARK: Screenshots fetch
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
    
    //MARK: Screenshots for DetailsVC
    private func downloadScreenShots(with indexPath: IndexPath, completion: @escaping([UIImage]) -> Void) {
        
        concurrentQueue.async(group: dispatchGroup) { [unowned self] in
            
            let game = games.value as! [Game]
            
            dispatchGroup.enter()
            guard let slug = game[indexPath.row].slug else { return }
            fetchScreenShots(gameSlug: slug) { images in
                LockMutex {
                    completion(images)
                    self.deleteRequests()
                    self.dispatchGroup.leave()
                }.start()
            }
        }
    }
    
    //MARK: After-fetch updates
    private func updateAfterFetchPublishers(with result: Publishers, completion: @escaping () -> Void) {
        
        nextPage = result.next
        prevPage = result.previous
        games.value += result.results
        deleteOneRequest()
        
        DispatchQueue.main.async {
            completion()
        }
    }
    
    
    private func updateAfterFetchGames(with result: Welcome, completion: @escaping () -> Void) {
        
        nextPage = result.next
        prevPage = result.previous
        games.value += result.results
        deleteOneRequest()
        
        DispatchQueue.main.async {
            completion()
        }
    }
    
    //MARK: IndexPath calculate
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
}



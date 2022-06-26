//
//  MainTableViewModel.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 14/06/2022.
//

import Foundation
import UIKit


class MainTableViewModel : MainTableViewModelProtocol {
    
    private var currentUUID = UUID()
    private var currentPageUUID = UUID()
    
    var currentPage: Int = 1
    var nextPage: String?
    var prevPage: String?
    
    var games: Observable<[Game]> = Observable([])
    
    
    func fetchGamesWith(page: Int? = nil, orUrl url: String? = nil, completion: @escaping () -> Void) {
        
        FetchSomeFilm.shared.cancelLoadAtUUID(uuid: currentPageUUID)
        
        self.currentPageUUID = FetchSomeFilm.shared.fetchWith(page: page, orUrl: url) { [unowned self] result in
            switch result {
            case .success(let result):
                nextPage = result.next
                prevPage = result.previous
                games = Observable(result.results)
                completion()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func updateSearchResults(text: String, completion: @escaping () -> Void) {
        
        FetchSomeFilm.shared.cancelLoadAtUUID(uuid: currentUUID)
        
        DispatchQueue.global().async {
            self.currentUUID = FetchSomeFilm.shared.findSomeGames(with: text) { [unowned self] result in
                switch result {
                case .success(let result):
                    DispatchQueue.main.async {
                        self.games = Observable(result.results)
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
        guard let urlForFetch = urlForFetch else { return }
        DispatchQueue.global().async {
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
}


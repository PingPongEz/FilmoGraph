//
//  MainTableViewModel.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 14/06/2022.
//

import Foundation
import UIKit


final class MainTableViewModel : MainTableViewModelProtocol {
    
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
    var currentRequest: UUID?
    
    var games: Observable<[Game]> = Observable([])
    
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
    
    func stopRequest() {
        URLResquests.shared.deleteOneRequest(request: self.currentRequest)
    }
}


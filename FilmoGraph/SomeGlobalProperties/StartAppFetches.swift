//
//  StartAppFetches.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 05/07/2022.
//

import Foundation

final class StartFetch {
    private init(){}
    
    static let shared = StartFetch()
    
    private var requests: [UUID?]? = []
    
    func fetchGameListForMainView(completion: @escaping (MainTableViewModelProtocol?) -> Void) {
        let mainTableViewModel = MainTableViewModel()
        
        let uuid = FetchSomeFilm.shared.fetchWith(page: 1, ordering: SortGames.added.rawValue, isReversed: true) { [unowned self] result in
            mainTableViewModel.games.value = result.results
            mainTableViewModel.nextPage = result.next
            mainTableViewModel.prevPage = result.previous
            mainTableViewModel.mainViewControllerState = .games
            URLResquests.shared.cancelRequests(requests: requests ?? [])
            completion(mainTableViewModel)
        }
        
        requests?.append(uuid)
    }
    
    func fetchPublishersListForMainView(completion: @escaping (MainTableViewModelProtocol?) -> Void) {
        let mainTableViewModel = MainTableViewModel()
        
        let uuid = FetchSomeFilm.shared.fetchPublishers(onPage: 1) { [unowned self] result in
            mainTableViewModel.games.value = result.results
            mainTableViewModel.nextPage = result.next
            mainTableViewModel.prevPage = result.previous
            mainTableViewModel.mainViewControllerState = .publishers
            URLResquests.shared.cancelRequests(requests: requests ?? [])
            completion(mainTableViewModel)
        }
        
        requests?.append(uuid)
    }
}

#if DEBUG

extension StartFetch {
    func _checkRequestsInStartFetch() -> [UUID?]? {
        return requests
    }
}

#endif

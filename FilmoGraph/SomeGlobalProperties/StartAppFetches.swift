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
        
        requests?.append( FetchSomeFilm.shared.fetchWith(page: 1) { [unowned self] result in
            mainTableViewModel.games.value = result.results
            mainTableViewModel.nextPage = result.next
            mainTableViewModel.prevPage = result.previous
            URLResquests.shared.cancelRequests(requests: requests ?? [])
            self.requests = nil
            completion(mainTableViewModel)
        })
    }
}

#if DEBUG

extension StartFetch {
    func _checkRequestsInStartFetch() -> [UUID?]? {
        return requests
    }
}

#endif

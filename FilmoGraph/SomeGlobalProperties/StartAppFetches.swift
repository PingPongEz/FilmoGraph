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
    
    private var requests = [UUID?]()
    
    func fetchGameListForMainView(completion: @escaping (MainTableViewModel?) -> Void) {
        let mainTableViewModel = MainTableViewModel()
        
        let uuid = FetchSomeFilm.shared.fetchWith(page: 1) { [unowned self] result in
            mainTableViewModel.games.value = result.results
            mainTableViewModel.nextPage = result.next
            mainTableViewModel.prevPage = result.previous
            URLResquests.shared.cancelRequests(requests: requests)
            completion(mainTableViewModel)
        }
        self.requests.append(uuid)
    }
}

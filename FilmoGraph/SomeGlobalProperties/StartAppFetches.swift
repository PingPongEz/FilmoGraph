//
//  StartAppFetches.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 05/07/2022.
//

import Foundation

class StartFetch {
    private init(){}
    
    static let shared = StartFetch()
    
    private var requests = [UUID?]()
    
    func fetchGameListForMainView(completion: @escaping (MainTableViewModel) -> Void) {
        let mainTableViewModel = MainTableViewModel()
        
        let uuid = FetchSomeFilm.shared.fetchWith(page: 1, search: "") { [unowned self] result in
            do {
                let welcome = try result.get()
                mainTableViewModel.games.value = welcome.results
                mainTableViewModel.nextPage = welcome.next
                mainTableViewModel.prevPage = welcome.previous
                URLResquests.shared.cancelRequests(requests: requests)
                completion(mainTableViewModel)
            } catch let error {
                print(error)
            }
        }
        self.requests.append(uuid)
    }
}

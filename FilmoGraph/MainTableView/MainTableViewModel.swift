//
//  MainTableViewModel.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 14/06/2022.
//

import Foundation

protocol MainTableViewModelProtocol {
    
    var games: Observable<[Game]> { get set }
    
    func fetchGames(completion: @escaping () -> Void)
    func cellForRowAt(_ indexPath: IndexPath) -> CellViewModelProtocol
}

class MainTableViewModel : MainTableViewModelProtocol {
    var games: Observable<[Game]> = Observable([])
    
    func fetchGames(completion: @escaping () -> Void) {
        FetchSomeFilm.shared.fetch { result in
            switch result {
            case .success(let result):
                self.games = Observable(result.results)
                completion()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func cellForRowAt(_ indexPath: IndexPath) -> CellViewModelProtocol {
        let game = games.value[indexPath.row]
        
        return CellViewModel(game: game)
    }
}


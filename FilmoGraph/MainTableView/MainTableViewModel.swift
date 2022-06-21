//
//  MainTableViewModel.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 14/06/2022.
//

import Foundation
import UIKit

protocol MainTableViewModelProtocol {
    
    var games: Observable<[Game]> { get set }
    
    func fetchGames(completion: @escaping () -> Void)
    func cellForRowAt(_ indexPath: IndexPath) -> CellViewModelProtocol
    func cellDidTap(_ indexPath: IndexPath) -> String
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
    
    func cellDidTap(_ indexPath: IndexPath) -> String {
        guard let string = games.value[indexPath.row].id else { return "" }
        return String("https://api.rawg.io/api/games/\(string)?key=7f01c67ed4d2433bb82f3dd38282088c")
    }
}


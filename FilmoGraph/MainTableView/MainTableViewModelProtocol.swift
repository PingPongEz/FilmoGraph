//
//  MainTableViewModelProtocol.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 22/06/2022.
//

import Foundation

protocol MainTableViewModelProtocol {
    
    var games: Observable<[Game]> { get set }
    
    func fetchGames(with page: Int, completion: @escaping () -> Void)
    func cellForRowAt(_ indexPath: IndexPath) -> CellViewModelProtocol
    func cellDidTap(_ indexPath: IndexPath) -> String
    func createDetailViewControllerModel(with urlForFetch: String?, completion: @escaping(GameDetais?) -> Void)
    func updateSearchResults(text: String ,completion: @escaping () -> Void)
    
}

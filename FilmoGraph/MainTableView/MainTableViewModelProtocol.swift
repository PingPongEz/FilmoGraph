//
//  MainTableViewModelProtocol.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 22/06/2022.
//

import Foundation

protocol MainTableViewModelProtocol {
    
    var games: Observable<[Game]> { get set }
    var nextPage: String? { get set }
    var prevPage: String? { get set }
    
    func updateSearchResults(text: String ,completion: @escaping () -> Void)
    func fetchGamesWith(page: Int?, orUrl url: String?, completion: @escaping () -> Void)
    func deleteRequests()
    func cellDidTap(_ indexPath: IndexPath) -> String
    func cellForRowAt(_ indexPath: IndexPath) -> CellViewModelProtocol
    func createDetailViewControllerModel(with urlForFetch: String?, completion: @escaping(GameDetais?) -> Void)
    
}

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
    var searchText: String { get set }
    var isShowAvailable: Bool { get set }
    
    func fetchGamesWith(page: Int?, orUrl url: String?, completion: @escaping () -> Void)
    func downloadEveryThingForDetails(with indexPath: IndexPath) -> DetailGameViewController
    func cellForRowAt(_ indexPath: IndexPath) -> CellViewModelProtocol
    
}

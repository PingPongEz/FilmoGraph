//
//  MainTableViewModelProtocol.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 22/06/2022.
//

import Foundation
import UIKit

protocol MainTableViewModelProtocol {
    
    var games: Observable<[Game]> { get set }
    var nextPage: String? { get set }
    var prevPage: String? { get set }
    var isShowAvailable: Bool { get set }
    var currentPage: Int { get set }
    var listOfRequests: [UUID?] { get set}
    var ordering: SortGames { get set }
    var isReversed: Observable<Bool> { get set }
    var isReversedString: String { get }
    var image: UIImage { get }
    
    func reverseSorting(completion: @escaping () -> Void)
    func createAlertController(completion: @escaping () -> Void) -> UIAlertController 
    func fetchGamesWith(completion: @escaping () -> Void)
    func downloadEveryThingForDetails(with indexPath: IndexPath) -> DetailGameViewController
    func cellForRowAt(_ indexPath: IndexPath) -> CellViewModelProtocol
    func deleteRequests()
    func deleteOneRequest()
    
}

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
    var currentGengre: Genre? { get set }
    var currentPlatform: Platform? { get set }
    var textForSearchFetch: String? { get set }
    var prevPage: String? { get set }
    var isShowAvailable: Bool { get set }
    var currentPage: Int { get set }
    var listOfRequests: [UUID?] { get set}
    var ordering: SortGames { get set }
    var isReversed: Observable<Bool> { get set }
    var isReversedString: String { get }
    var image: UIImage { get }
    var isSearchingViewController: Bool { get set }
    
    func reverseSorting(startAction: @escaping () -> Void, completion: @escaping ([IndexPath]) -> Void)
    func createAlertController(startAction: @escaping() -> Void, completion: @escaping ([IndexPath]) -> Void) -> UIAlertController
    func fetchGamesWith(completion: @escaping ([IndexPath]) -> Void) //Scrolling
    func searchFetch(completion: @escaping ([IndexPath]) -> Void) //Searching
    func downloadEveryThingForDetails(with indexPath: IndexPath) -> DetailGameViewController
    func cellForRowAt(_ indexPath: IndexPath) -> CellViewModelProtocol
    func deleteRequests()
    func deleteOneRequest()
    
}

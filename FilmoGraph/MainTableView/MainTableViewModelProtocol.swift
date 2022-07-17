//
//  MainTableViewModelProtocol.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 22/06/2022.
//

import Foundation
import UIKit

protocol MainTableViewModelProtocol {
    
    var games: Observable<[Any]> { get set }
    
    var nextPage: String? { get set }               //Needs to check before fetching next page
    var currentGengre: Genre? { get set }           //Needs to search
    var currentPlatform: Platform? { get set }      //Needs to search
    var textForSearchFetch: String? { get set }     //Needs to search
    var prevPage: String? { get set }               //Don't need it?
    var isShowAvailable: Bool { get set }           //Needs to lock .show func
    var currentPage: Int { get set }                //Needs while fetching with page
    var listOfRequests: [UUID?] { get set}          //Needs to delete completed requests and stop requests
    var ordering: SortGames { get set }             //Kind of sorting 
    var isReversed: Observable<Bool> { get set }    //Needs to reverse sorting
    var mainViewControllerState: MainViewControllerState { get set }   //Needs to watch at viewController state (Search, not search...)
    
    func reverseSorting(startAction: @escaping () -> Void, completion: @escaping ([IndexPath]) -> Void)
    func createAlertController(startAction: @escaping() -> Void, completion: @escaping ([IndexPath]) -> Void) -> UIAlertController
    func fetchGamesWith(completion: @escaping ([IndexPath]) -> Void) //Scrolling
    func searchFetch(completion: @escaping ([IndexPath]) -> Void) //Searching
    func fetchPublishers(completion: @escaping ([IndexPath]) -> Void)
    func downloadEveryThingForDetails(with indexPath: IndexPath) -> DetailGameViewController
    func cellForRowAt(_ indexPath: IndexPath) -> CellViewModelProtocol
    func deleteRequests()
    func deleteOneRequest()
    
}

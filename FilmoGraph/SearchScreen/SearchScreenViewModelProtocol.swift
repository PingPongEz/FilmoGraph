//
//  SearchScreenViewModelProtocol.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 07/07/2022.
//

import Foundation
import UIKit

protocol SearchScreenViewModelProtocol {
    
    var currentGanre: Genre? { get set }
    var currentPlatform: Platform? { get set }
    
    func platformSelectedButtonPressed()
    func ganreSelectedButtonPressed()
    func numberOfRowsInSection(section: Int, tableVieewType: TableViewType?) -> Int
    func cellForRowAt(_ tableView: UITableView, at indexPath: IndexPath, tableViewType: TableViewType?) -> UITableViewCell
    func didSelectRowAt(indexPath: IndexPath, tableViewType: TableViewType?, completion: @escaping (String) -> Void)
    func dismissTableViews()
    func findButtonPressed(completiong: @escaping (MainTableViewController) -> Void)
    
}

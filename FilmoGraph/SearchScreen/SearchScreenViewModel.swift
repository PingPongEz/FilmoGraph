//
//  SearchScreenViewModel.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 07/07/2022.
//

import Foundation
import UIKit

final class SearchScreenViewModel: SearchScreenViewModelProtocol {
    
    var currentGanre: Genre?
    var isGanreContainerOpened = false
    var ganreHeight: NSLayoutConstraint?
    var ganreButtonText = "Choose game ganre..."
    
    var currentPlatform: Platform?
    var iscurrentPlatformOpened = false
    var platformHeight: NSLayoutConstraint?
    var platformButtonText = "Choose game platform..."
    
    func ganreSelectedButtonPressed() {
        isGanreContainerOpened
        ? (ganreHeight?.constant = 0)
        : (ganreHeight?.constant = 150)
        isGanreContainerOpened.toggle()
    }
    
    func platformSelectedButtonPressed() {
        iscurrentPlatformOpened
        ? (platformHeight?.constant = 0)
        : (platformHeight?.constant = 150)
        iscurrentPlatformOpened.toggle()
    }
    
    func numberOfRowsInSection(section: Int, tableVieewType: TableViewType?) -> Int {
        if tableVieewType == .genre {
            return (GlobalProperties.shared.genres?.value.results?.count ?? 0) + 1
        } else if tableVieewType == .platform {
            return (GlobalProperties.shared.platforms.value.count) + 1
        }
        return 0
    }
    
    func cellForRowAt(_ tableView: UITableView, at indexPath: IndexPath, tableViewType: TableViewType?) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        if indexPath.row == 0 {
            
            if tableViewType == .genre {
                content.text = ganreButtonText
            } else if tableViewType == .platform {
                content.text = platformButtonText
            }
            
        } else if tableViewType == .genre {
            content.text = GlobalProperties.shared.genres?.value.results?[indexPath.row - 1].name
        } else if tableViewType == .platform {
            content.text = GlobalProperties.shared.platforms.value[indexPath.row - 1].name
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    func didSelectRowAt(indexPath: IndexPath, tableViewType: TableViewType?, completion: @escaping (String) -> Void) {
        
        var text = ""
        
        if indexPath.row == 0 {
            
            if tableViewType == .genre {
                currentGanre = nil
                isGanreContainerOpened = false
                ganreHeight?.constant = 0
                text = ganreButtonText
            } else if tableViewType == .platform {
                currentPlatform = nil
                iscurrentPlatformOpened = false
                platformHeight?.constant = 10
                text = platformButtonText
            }
            
        } else if tableViewType == .genre {
            currentGanre = GlobalProperties.shared.genres?.value.results?[indexPath.row - 1]
            isGanreContainerOpened = false
            ganreHeight?.constant = 0
            text = currentGanre?.name ?? ""
        } else if tableViewType == .platform {
            currentPlatform = GlobalProperties.shared.platforms.value[indexPath.row - 1]
            iscurrentPlatformOpened = false
            platformHeight?.constant = 0
            text = currentPlatform?.name ?? ""
        }
        
        completion(text)
    }
    
    func dismissTableViews() {
        
        ganreHeight?.constant = 0
        isGanreContainerOpened = false
        
        platformHeight?.constant = 0
        iscurrentPlatformOpened = false
    }
    
    func findButtonPressed(completion: @escaping (MainTableViewController) -> Void) {
        let _ = FetchSomeFilm.shared.searchFetch(onPage: 1, ganre: currentGanre?.id, platform: currentPlatform?.id) { [unowned self] result in
            let searchVCVM = MainTableViewModel()
            searchVCVM.games.value = result.results
            
            let searchVC = MainTableViewController()
            searchVC.viewModel = searchVCVM
            searchVC.viewModel.isSearchingViewController = true
            searchVC.viewModel.currentPage = 2
            searchVC.viewModel.currentGengre = currentGanre
            searchVC.viewModel.currentPlatform = currentPlatform
            
            DispatchQueue.global().async {
                completion(searchVC)
            }
        }
    }
}

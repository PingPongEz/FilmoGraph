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
    var isGanreCotainerOpened = false
    var ganreHeight: NSLayoutConstraint?
    
    var currentPlatform: Platform?
    var iscurrentPlatformOpened = false
    var platformHeight: NSLayoutConstraint?
    
    func setHeight() {
        UIView.animate(withDuration: 2) { [unowned self] in
            isGanreCotainerOpened ? (height?.constant = 1000) : (height?.constant = 0)
        }
    }
    
    var height: NSLayoutConstraint?
    
    func platformSelectedButtonPressed() {
        
    }
    
    func ganreSelectedButtonPressed() {
        
    }
    
    func startSearchButtonPressed() {
        
    }
}

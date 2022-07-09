//
//  SearchScreenViewModelProtocol.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 07/07/2022.
//

import Foundation

protocol SearchScreenViewModelProtocol {
    
    var currentGanre: Genre? { get set }
    var currentPlatform: Platform? { get set }
    
    func platformSelectedButtonPressed()
    func ganreSelectedButtonPressed()
    func startSearchButtonPressed()
    
}

//
//  DetailGameViewModel.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 20/06/2022.
//

import Foundation
 
class DetailGameViewModel: DetailGameViewModelProtocol {
    
    private var game: Game!
    
    var gameName: String {
        ""
    }
    
    var gameDescription: String {
        ""
    }
    
    var gamePicture: String {
        ""
    }
    
    var gamePlatforms: String {
        ""
    }
    
    var gameRate: String {
        ""
    }
    
    init(game: Game) {
        self.game = game
    }
}

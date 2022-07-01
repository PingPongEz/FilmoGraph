//
//  DetailGameViewModel.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 20/06/2022.
//

import Foundation
import UIKit

final class DetailGameViewModel: DetailGameViewModelProtocol {
    
    var listOfRequests: [UUID?] = []
    
    var game: GameDetais?
    
    var images: [UIImage] = []
    
    var gameName: String {
        return game?.name ?? ""
    }
    
    var gameDescription: String {
        game?.description ?? ""
    }
    
    var gamePlatforms: String {
        guard let game = game else { return "" }
        let array = game.platforms?.compactMap { $0.platform?.name }
        guard let array = array else { return "" }
        return (array.joined(separator: ", "))
    }
    
    var gameRate: String {
        String("\(game?.rating) / \(game?.ratingTop)")
    }
    
    func setImages(images: [UIImage]) {
        self.images = images
    }
    
    
    init(game: GameDetais?) {
        self.game = game
    }
}

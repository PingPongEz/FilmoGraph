//
//  DetailGameViewModel.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 20/06/2022.
//

import Foundation
import UIKit
 
class DetailGameViewModel: DetailGameViewModelProtocol {
    
    private var game: Observable<GameDetais>?
    
    var gameName: String {
        print(game?.value)
        return game?.value.name ?? ""
    }
    
    var gameDescription: String {
        game?.value.description ?? ""
    }
    
    var gamePicture: Observable<UIImage?> {
        let image = Observable<UIImage?>(nil)
        
        guard let url = URL(string: game?.value.backgroundImage ?? "") else { return Observable<UIImage?>(UIImage(systemName: "person.filled")) }
        
            ImageLoader().loadImage(url) { result in
                do {
                    let loadedImage = try result.get()
                    DispatchQueue.main.async {
                        image.value = loadedImage
                    }
                } catch {
                    print(error)
                }
            }
        return image
    }
    
    var gamePlatforms: String {
        let array = game?.value.platforms.compactMap { $0.name }
        return (array?.joined(separator: ", ")) ?? "No platforms?"
    }
    
    var gameRate: String {
        String("\(game?.value.rating) / \(game?.value.ratingTop)")
    }
    
    init(game: Observable<GameDetais>?) {
        self.game = game
    }
}

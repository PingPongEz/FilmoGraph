//
//  DetailGameViewModel.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 20/06/2022.
//

import Foundation
import UIKit
 
class DetailGameViewModel: DetailGameViewModelProtocol {
    
    var game: GameDetais?
    
    var gameName: String {
        return game?.name ?? ""
    }
    
    var currentUUID: UUID?
    
    
    var gameDescription: String {
        game?.description ?? ""
    }
    
    var gamePicture: Observable<UIImage?> {
        let image = Observable<UIImage?>(nil)
        guard let url = URL(string: game?.backgroundImage ?? "") else { return Observable<UIImage?>(UIImage(systemName: "person.filled")) }
           currentUUID = ImageLoader().loadImage(url) { result in
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
        guard let game = game else { return "" }
        let array = game.platforms?.compactMap { $0.platform?.name }
        guard let array = array else { return "" }
        return (array.joined(separator: ", "))
    }
    
    var gameRate: String {
        String("\(game?.rating) / \(game?.ratingTop)")
    }
    
    func createDetailViewControllerModel(with urlForFetch: String?, completion: @escaping(GameDetais?) -> Void) {
        guard let urlForFetch = urlForFetch else { return }
        DispatchQueue.global().async {
            FetchSomeFilm.shared.fetchGameDetails(with: urlForFetch) { result in
                do {
                    let details = try result.get()
                    DispatchQueue.main.async {
                        completion(details)
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
    
    init(game: GameDetais?) {
        self.game = game
    }
}

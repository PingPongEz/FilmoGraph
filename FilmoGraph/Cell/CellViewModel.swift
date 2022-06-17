//
//  CellViewModel.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 15/06/2022.
//

import Foundation
import UIKit

protocol CellViewModelProtocol: AnyObject {
    var gamePic: Observable<UIImage?> { get }
    var gameName: String { get }
    var gameType: String { get }
    var platform: String { get }
    var gameCreator: String { get }
    var onReuse: () -> Void { get }
    init(game: Game)
}

class CellViewModel: CellViewModelProtocol {
    var onReuse: () -> Void = {}
    
    private let game: Game!
    
    let loader = ImageLoader()
    
    var gamePic: Observable<UIImage?> {
        let image = Observable<UIImage?>(UIImage(systemName: "person"))
        
        guard let url = URL(string: game.backgroundImage ?? "") else { return Observable<UIImage?>(UIImage(systemName: "person"))}
        
        let tocken = loader.loadImage(url) { result in
            
            do {
                let imageView = try result.get()
                DispatchQueue.main.async {
                    image.value = imageView
                }
                
            } catch {
                print(error)
            }
            
//            switch result {
//            case .success(let pic):
//                print(self.game.backgroundImage)
//                image.value = pic
//                return
//            case .failure(let error):
//                print("AAAAAA")
//                print(error.localizedDescription)
//            }
            self.onReuse = {
                if let tocken = tocken {
                    self.loader.cancelLoad(tocken)
                }
            }
        }
        return image
    }
    
    var gameName: String {
        game.name ?? "No data"
    }
    
    var gameType: String {
        game.slug ?? "No data"
    }
    
    var platform: String {
        let array = game.platforms?.compactMap { $0.platform?.name }
        guard let text = array?.joined(separator: ", ") else { return "" }
        return text
    }
    
    var gameCreator: String {
        "Some creator"
    }
    
    required init(game: Game) {
        self.game = game
    }
    
}

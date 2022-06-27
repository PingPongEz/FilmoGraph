//
//  CellViewModel.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 15/06/2022.
//

import Foundation
import UIKit


class CellViewModel: CellViewModelProtocol {
    
    private let game: Game!
    
    var onReuse: UUID?
    
    var gamePic: Observable<UIImage?> {
        let image = Observable<UIImage?>(nil)
        
        guard let url = URL(string: game.backgroundImage ?? "") else { return Observable<UIImage?>(UIImage(systemName: "person"))}
        DispatchQueue.global().async { [unowned self] in
            self.onReuse = ImageLoader.shared.loadImage(url) { result in
                do {
                    let imageView = try result.get()
                    DispatchQueue.main.async {
                        image.value = imageView
                        URLResquests.shared.deleteOneRequest(request: self.onReuse)
                    }
                } catch {
                    print(error)
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
    
    func stopCellRequest() {
        URLResquests.shared.deleteOneRequest(request: onReuse)
    }
    
    required init(game: Game) {
        self.game = game
    }
    
}

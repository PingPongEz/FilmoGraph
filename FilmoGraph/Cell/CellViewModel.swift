//
//  CellViewModel.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 15/06/2022.
//

import Foundation
import UIKit


final class CellViewModel: CellViewModelProtocol {
    
    private let game: Game!
    
    var onReuse: UUID?
    
    var gamePic: Observable<UIImage?> {
        let image = Observable<UIImage?>(nil)
        
        guard let url = URL(string: game.backgroundImage ?? "") else { return Observable<UIImage?>(UIImage(systemName: "person"))}
        self.onReuse = ImageLoader.shared.loadImage(url) { result in
            switch result {
            case .success(let resultImage):
                DispatchQueue.main.async {
                    image.value = resultImage
                    self.stopCellRequest()
                }
            case .failure(let error):
                print(error)
            }
        }
        return image
    }
    
    var gameName: String {
        game.name ?? "No data"
    }
    
    var gameType: String {
        let array = game.genres?.compactMap { $0.name }
        guard let text = array?.joined(separator: ", ") else { return "" }
        return text
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

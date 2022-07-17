//
//  CellViewModel.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 15/06/2022.
//

import Foundation
import UIKit


final class CellViewModel: CellViewModelProtocol {
    
    private let cellValue: Any!
    
    var onReuse: UUID?
    
    var gamePic: Observable<UIImage?> {
        
        let image = Observable<UIImage?>(nil)
        var urlString = ""
        
        if cellValue as? Game != nil {
            urlString = (cellValue as? Game)?.backgroundImage ?? ""
        } else if cellValue as? Publisher != nil {
            urlString = (cellValue as? Publisher)?.imageBackground ?? ""
        }
        
        guard let url = URL(string: urlString) else { return Observable<UIImage?>(UIImage(systemName: "person"))}
        
        self.onReuse = ImageLoader.shared.loadImageWithData(url) { result in
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
    
    var cellName: String {
        
        if let game = cellValue as? Game {
            return game.name ?? "No data"
        } else if let publisher = cellValue as? Publisher {
            return publisher.name ?? "No name"
        }
        
        return ""
        
    }
    
    var cellSecondaryName: String {
        
        if let game = cellValue as? Game {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return "Released at - " + formatter.string(from: game.released ?? Date())
            
        } else if let publisher = cellValue as? Publisher {
            return "Popular games - \(publisher.gamesCount ?? 0)"
        }
        return ""
    }
    
    var cellThirdName: String {
        if let game = cellValue as? Game {
            guard let metacritic = game.metacritic else { return "No metacritics data" }
            return "Metacritic - \(metacritic) / 100"
        } else if let publisher = cellValue as? Publisher {
            
        }
        return ""
    }
    
    func stopCellRequest() {
        URLResquests.shared.deleteOneRequest(request: onReuse)
    }
    
    init(publisher: Publisher) {
        self.cellValue = publisher
    }
    
    required init(game: Game) {
        self.cellValue = game
    }
}

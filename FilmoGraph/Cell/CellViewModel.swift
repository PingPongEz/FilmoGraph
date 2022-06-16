//
//  CellViewModel.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 15/06/2022.
//

import Foundation
import UIKit

protocol CellViewModelProtocol: AnyObject {
    var gamePic: Data { get }
    var gameName: String { get }
    var gameType: String { get }
    var platform: String { get }
    var gameCreator: String { get }
    var cellChanged: ((CellViewModelProtocol) -> Void)? { get set }
    init(game: Game)
}

class CellViewModel: CellViewModelProtocol {
    
    var cellChanged: ((CellViewModelProtocol) -> Void)?
    
    private let game: Game!
    
    var gamePic: Data {
        
        var dataPic = Data()
        
        guard let url = URL(string: game.backgroundImage ?? "") else { return Data() }
        
        if let cachedImage = getCachedImage(from: url) {
            cellChanged?(self)
            return cachedImage
        }
        
        FetchSomeFilm.shared.fetchImageFrom(url: url) { data, response in
            self.cacheImage(with: data, response)
            dataPic = data
        }
        
        cellChanged?(self)
        return dataPic
    }
    
    private func cacheImage(with data: Data, _ response: URLResponse) {
        guard let url = response.url else { return }
        
        let request = URLRequest(url: url)
        let response = CachedURLResponse(response: response, data: data)
        print("Cached \(game.name)")
        
        URLCache.shared.storeCachedResponse(response, for: request)
    }
    
    private func getCachedImage(from url: URL) -> Data? {
        let request = URLRequest(url: url)
        
        if let cachedResponce = URLCache.shared.cachedResponse(for: request) {
            return cachedResponce.data
        }
        
        return nil
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

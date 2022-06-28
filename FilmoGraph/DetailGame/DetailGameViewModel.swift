//
//  DetailGameViewModel.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 20/06/2022.
//

import Foundation
import UIKit

final class DetailGameViewModel: DetailGameViewModelProtocol {
    
    var game: GameDetais?
    private var screenShots: [ScreenShotsResult]?
    
    var images: [UIImage] = []
    var listOfRequests: [UUID?] = []
    
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
    
    func fetchScreenShots(completion: @escaping() -> Void) {
        
        DispatchQueue.global().async { [unowned self] in
            let request = FetchSomeFilm.shared.fetchScreenShots(with: game?.slug ?? "") { result in
                do {
                    let images = try result.get()
                    DispatchQueue.main.async {
                        self.screenShots = images.results
                        self.unpackScreenshots {
                            completion()
                        }
                    }
                } catch {
                    print(error)
                }
            }
            listOfRequests.append(request)
        }
    }
    
    private func unpackScreenshots(completion: @escaping () -> Void) {
        DispatchQueue.global().async { [unowned self] in
            screenShots?.forEach { url in
                guard let url = URL(string: url.image ?? "") else { return }
                let request = ImageLoader.shared.loadImage(url) { result in  //MARK: Make delete from requests with protocol
                    do {
                        let image = try result.get()
                        DispatchQueue.main.async {
                            self.images.append(image)
                            if self.images.count == self.screenShots?.count {  //MARK: For only one completion call
                                completion()
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
                listOfRequests.append(request)
            }
        }
    }
    
    init(game: GameDetais?) {
        self.game = game
    }
}

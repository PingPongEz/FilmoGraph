//
//  CellViewModelProtocol.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 22/06/2022.
//

import Foundation
import UIKit

protocol CellViewModelProtocol: AnyObject {
    var gamePic: Observable<UIImage?> { get }
    var onReuse: UUID? { get }
    var gameName: String { get }
    var gameType: String { get }
    var platform: String { get }
    var gameCreator: String { get }
//    var onReuse: UUID? { get set }
    func stopCellRequest()
    init(game: Game)
}

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
    var cellName: String { get }
    var cellSecondaryName: String { get }
    var cellThirdName: String { get }
    
    func stopCellRequest()
    init(game: Game)
}

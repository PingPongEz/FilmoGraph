//
//  DetailGameViewModelProtocol.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 20/06/2022.
//

import Foundation
import UIKit

protocol DetailGameViewModelProtocol: AnyObject {
    
    //    var gamePicture: Observable<UIImage?> { get }
    var gameName: String { get }
    var gameDescription: String { get }
    var gamePlatforms: String { get }
    var gameRate: String { get }
    func fetchScreenShots(completion: @escaping() -> Void)
    
}

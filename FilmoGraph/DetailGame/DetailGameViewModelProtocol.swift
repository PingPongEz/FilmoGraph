//
//  DetailGameViewModelProtocol.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 20/06/2022.
//

import Foundation
import UIKit

protocol DetailGameViewModelProtocol: AnyObject {
    
    var gameName: String { get }
    var gameDescription: String { get }
    var gamePicture: Observable<UIImage?> { get }
    var gamePlatforms: String { get }
    var gameRate: String { get }
    
}

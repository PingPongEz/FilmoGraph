//
//  DetailGameViewModelProtocol.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 20/06/2022.
//

import Foundation

protocol DetailGameViewModelProtocol: AnyObject {
    
    var gameName: String { get }
    var gameDescription: String { get }
    var gamePicture: String { get }
    var gamePlatforms: String { get }
    var gameRate: String { get }
    
}

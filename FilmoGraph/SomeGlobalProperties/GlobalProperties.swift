//
//  GlobalProperties.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 07/07/2022.
//

import Foundation
import UIKit

final class GlobalProperties {
    
    private init(){}
    
    static let shared = GlobalProperties()
    
    var platforms: Observable<[Platform]> = Observable([])
    
    var genres: Observable<Genres>?
    
}

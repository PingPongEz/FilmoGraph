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
    
    func shadowOnScrolling(_ nav: UINavigationBar?) {
        
        nav?.layer.shadowPath = UIBezierPath(roundedRect: nav?.bounds ?? CGRect(), cornerRadius: 2).cgPath
        nav?.layer.shadowColor = UIColor.black.cgColor
        nav?.layer.shadowRadius = 5
        nav?.layer.shadowOffset = CGSize(width: 0, height: 4)
        nav?.layer.shadowOpacity = 0.6
        
    }
}

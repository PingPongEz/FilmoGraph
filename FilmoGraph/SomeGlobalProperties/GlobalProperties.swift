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
    
    func setNavBarShadow(_ navBar: UINavigationController, _ tabBar: UITabBarController) {
        
        navBar.navigationBar.layer.shadowPath = UIBezierPath(roundedRect: navBar.navigationBar.bounds, cornerRadius: 2).cgPath
        navBar.navigationBar.layer.shadowColor = UIColor.black.cgColor
        navBar.navigationBar.layer.shadowRadius = 5
        navBar.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 4)
        navBar.navigationBar.layer.shadowOpacity = 0.6
        
        
        tabBar.tabBar.layer.shadowPath = UIBezierPath(roundedRect: tabBar.tabBar.bounds, cornerRadius: 2).cgPath
        tabBar.tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.tabBar.layer.shadowRadius = 3.5
        tabBar.tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
        tabBar.tabBar.layer.shadowOpacity = 0.45
        
    }
}

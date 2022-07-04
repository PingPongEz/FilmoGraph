//
//  TabBar.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 04/07/2022.
//

import UIKit

class TabBar: UITabBarController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.insetsLayoutMarginsFromSafeArea = true
        view.backgroundColor = UIColor(red: 65/255, green: 144/255, blue: 255/255, alpha: 1)
        UITabBar.appearance().barTintColor = UIColor(red: 65/255, green: 144/255, blue: 255/255, alpha: 1)
        
        view.backgroundColor = .white
        tabBar.tintColor = .white
        setupVC()
    }
    
    private func setupVC() {
        viewControllers = [
            addNavBar(for: MainTableViewController(), title: "Games", image: UIImage(systemName: "gamecontroller")!)
        ]
    }
    
    private func addNavBar(for rootVC: UIViewController, title: String, image: UIImage) -> UIViewController {
        
        let navigationController = UINavigationController(rootViewController: rootVC)
        
        let navbarapp = UINavigationBarAppearance()
        
        navbarapp.backgroundColor = UIColor(red: 65/255, green: 144/255, blue: 255/255, alpha: 1)
        navbarapp.titleTextAttributes = [.foregroundColor: UIColor.white]
        navbarapp.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
//        navigationItem.leftBarButtonItem?.isEnabled = false
        
        navigationController.tabBarItem.title = title
        navigationController.tabBarItem.image = image
        rootVC.navigationItem.title = title
        
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.tintColor = .white
        navigationController.navigationBar.standardAppearance = navbarapp
        navigationController.navigationBar.scrollEdgeAppearance = navbarapp
        
        return navigationController
    }
}

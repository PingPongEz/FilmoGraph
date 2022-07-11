//
//  TabBar.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 04/07/2022.
//

import UIKit

class TabBar: UITabBarController, UITabBarControllerDelegate {
    
    var selectedInd = 2
    
    lazy var selectionView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .black
        view.layer.opacity = 0.15
        view.isUserInteractionEnabled = false
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        view.backgroundColor = .white
        
        tabBar.addSubview(selectionView)
        tabBar.isHidden = true
        
        tabBarAppearence()
        
        tabBar.tintColor = .white
        
        setupVC()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0001) {
            self.addSomethings()
        }
    }
    
    
    private func setupVC() {
        
        let mainTableVC = MainTableViewController()
        let platformsUrl = "https://api.rawg.io/api/platforms?key=7f01c67ed4d2433bb82f3dd38282088c&page=1"
        
        let queue = DispatchQueue(label: "Concurrent Queue", qos: .utility, attributes: .concurrent)
        let group = DispatchGroup()
        
        group.enter()
        queue.async(group: group) {
            StartFetch.shared.fetchGameListForMainView() { viewModel in
                mainTableVC.viewModel = viewModel
                group.leave()
            }
        }
        
        group.enter()
        queue.async(group: group) {
            FetchSomeFilm.shared.fetchGenres() {
                group.leave()
            }
        }
        
        group.enter()
        queue.async(group: group) {
            FetchSomeFilm.shared.fetchAllPlatforms(with: platformsUrl) {
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [unowned self] in
            viewControllers = [
                addNavBar(for: mainTableVC, title: "Games", image: UIImage(systemName: "gamecontroller")!),
                addNavBar(for: SearchScreenViewController(), title: "Search", image: UIImage(systemName: "magnifyingglass")!)
            ]
            tabBar.isHidden = false
            addSomethings()
        }
    }
    
    private func addSomethings() {
        selectionView.frame.size = CGSize(width: tabBar.bounds.width / CGFloat(viewControllers?.count ?? 0), height: tabBar.bounds.height)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) { [unowned self] in
            selectionView.frame.origin.x = tabBar.frame.width * (CGFloat(selectedIndex) / CGFloat(viewControllers?.count ?? 0))
        }
    }
    
    private func addNavBar(for rootVC: UIViewController, title: String, image: UIImage) -> UIViewController {
        
        let navigationController = UINavigationController(rootViewController: rootVC)
        
        let navbarapp = UINavigationBarAppearance()
        
        navbarapp.backgroundColor = UIColor.myBlueColor
        navbarapp.titleTextAttributes = [.foregroundColor: UIColor.white]
        navbarapp.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController.tabBarItem.title = title
        navigationController.tabBarItem.image = image
        rootVC.navigationItem.title = title
        
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.tintColor = .white
        navigationController.navigationBar.standardAppearance = navbarapp
        navigationController.navigationBar.scrollEdgeAppearance = navbarapp
        
        return navigationController
    }
    
    private func tabBarAppearence() {
        let appearence = UITabBarAppearance()
        
        appearence.configureWithDefaultBackground()
        appearence.stackedLayoutAppearance.focused.badgeBackgroundColor = .white
        appearence.backgroundColor = UIColor.myBlueColor
        appearence.shadowColor = .black
        appearence.stackedLayoutAppearance.normal.iconColor = UIColor.black
        appearence.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        tabBar.standardAppearance = appearence
        tabBar.scrollEdgeAppearance = appearence
    }
}

extension UIColor {
    static let myBlueColor: UIColor = {
        return UIColor(red: 65/255, green: 144/255, blue: 255/255, alpha: 1)
    }()
}

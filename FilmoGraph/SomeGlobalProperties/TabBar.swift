//
//  TabBar.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 04/07/2022.
//

import UIKit

class TabBar: UITabBarController, UITabBarControllerDelegate {
    
    var selectedInd = 1
    
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
        tabBar.addSubview(selectionView)
        tabBar.isHidden = true
        view.backgroundColor = UIColor(red: 65/255, green: 144/255, blue: 255/255, alpha: 1)
        view.backgroundColor = .white
        UITabBar.appearance().barTintColor = UIColor(red: 65/255, green: 144/255, blue: 255/255, alpha: 1)
        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = .white
        
        
        setupVC()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0001) {
            self.addSomethings()
        }
    }
    
    
    private func setupVC() {
        
        let mainTableVC = MainTableViewController()
        StartFetch.shared.fetchGameListForMainView() { [unowned self] viewModel in
            mainTableVC.viewModel = viewModel
            viewControllers = [
                addNavBar(for: mainTableVC, title: "Games", image: UIImage(systemName: "gamecontroller")!),
                addNavBar(for: LoadingViewController(), title: "Red screen", image: UIImage(systemName: "person")!)
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
        
        navbarapp.backgroundColor = UIColor(red: 65/255, green: 144/255, blue: 255/255, alpha: 1)
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
}

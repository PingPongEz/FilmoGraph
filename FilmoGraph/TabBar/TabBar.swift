//
//  TabBar.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 04/07/2022.
//

import UIKit

class TabBar: UITabBarController, UITabBarControllerDelegate {
    
    
    let mainTableVC = MainTableViewController()
    let publishersVC = MainTableViewController()
    
    var selectedInd = 2
    let queue = GlobalQueueAndGroup.shared.queue
    let group = GlobalQueueAndGroup.shared.group
    
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
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.addSelectionView()
        }
    }
    
    private func fetchGameModel(completion: @escaping (MainTableViewModelProtocol?) -> Void) {
        queue.async(group: group) { [weak self] in
            self?.group.enter()
            StartFetch.shared.fetchGameListForMainView() { viewModel in
                completion(viewModel)
                self?.group.leave()
                Mutex.shared.available = true
                pthread_cond_signal(&Mutex.shared.condition)
            }
        }
    }
    
    
    private func fetchPublishersViewModel(comletion: @escaping (MainTableViewModelProtocol?) -> Void) {
        queue.async(group: group) { [weak self] in
            self?.group.enter()
            LockMutex {                                         //Rawg can't give more than one 200...299 response in moment
                StartFetch.shared.fetchPublishersListForMainView { viewModel in
                    comletion(viewModel)
                    self?.group.leave()
                }
            }.start()
        }
    }
    
    private func fetchGenresForApp() {
        queue.async(group: group) { [weak self] in
            self?.group.enter()
            FetchSomeFilm.shared.fetchGenres() { genres in
                GlobalProperties.shared.genres = Observable(genres)
                self?.group.leave()
            }
        }
    }
    
    private func fetchAllPlatforms() {
        let platformsUrl = "https://api.rawg.io/api/platforms?key=7f01c67ed4d2433bb82f3dd38282088c&page=1"
        
        queue.async(group: group) { [weak self] in
            self?.group.enter()
            FetchSomeFilm.shared.fetchAllPlatforms(with: platformsUrl) { platforms in
                GlobalProperties.shared.platforms.value += platforms
                self?.group.leave()
            }()
        }
    }
    
    private func setupVC() {
        
        fetchGameModel { [weak self] viewModel in
            self?.mainTableVC.viewModel = viewModel
        }
        
        fetchPublishersViewModel { [weak self] viewModel in
            self?.publishersVC.viewModel = viewModel
        }
        
        fetchGenresForApp()
        
        fetchAllPlatforms()
        
        group.notify(queue: .main) { [weak self] in
            
            guard let self = self else { return }
            
            let searchViewController = SearchScreenViewController()
            let searchViewControllerViewModel = SearchScreenViewModel()
            searchViewController.viewModel = searchViewControllerViewModel
            
            self.viewControllers = [
                self.addNavBar(for: self.mainTableVC, title: "Games", image: UIImage(systemName: "gamecontroller")!),
                self.addNavBar(for: self.publishersVC, title: "Publishers", image: UIImage(systemName: "tortoise")!),
                self.addNavBar(for: searchViewController, title: "Search", image: UIImage(systemName: "magnifyingglass")!)
            ]
            self.tabBar.isHidden = false
            self.addSelectionView()
        }
    }
    
    private func addSelectionView() {
        selectionView.frame.size = CGSize(width: tabBar.bounds.width / CGFloat(viewControllers?.count ?? 0), height: tabBar.bounds.height)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            self.selectionView.frame.origin.x = self.tabBar.frame.width * (CGFloat(self.selectedIndex) / CGFloat(self.viewControllers?.count ?? 0))
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
        appearence.stackedLayoutAppearance.normal.iconColor = UIColor.black
        appearence.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        tabBar.standardAppearance = appearence
        tabBar.scrollEdgeAppearance = appearence
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            self?.addSelectionView()
        }
    }
}

#if DEBUG
extension TabBar {
    
    func _fetchGameModel(completion: @escaping (MainTableViewModelProtocol?) -> Void) {
        fetchGameModel { mainViewModel in
            completion(mainViewModel)
        }
    }
    
    func _fetchGameGenres(completionTwo: @escaping (Genres) -> Void) {
        fetchGenresForApp()
    }
}
#endif

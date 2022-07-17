//
//  TabBar.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 04/07/2022.
//

import UIKit

class TabBar: UITabBarController, UITabBarControllerDelegate {
    
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0001) {
            self.addSomethings()
        }
    }
    
    private func fetchGameModel(completion: @escaping (MainTableViewModelProtocol?) -> Void) {
        queue.async(group: group) { [unowned self] in
            group.enter()
            StartFetch.shared.fetchGameListForMainView() { viewModel in
                completion(viewModel)
                self.group.leave()
                Mutex.shared.available = true
                pthread_cond_signal(&Mutex.shared.condition)
            }
        }
    }
    
    private func fetchPublishersViewModel(comletion: @escaping (MainTableViewModelProtocol?) -> Void) {
        queue.async(group: group) { [unowned self] in
            group.enter()
            LockMutex {                                         //Rawg can't give more than one 200...299 response in moment
                StartFetch.shared.fetchPublishersListForMainView { viewModel in
                    comletion(viewModel)
                    self.group.leave()
                }
            }.start()
        }
    }
    
    private func fetchGenresForApp(completion: @escaping (Genres) -> Void) {
        queue.async(group: group) { [unowned self] in
            group.enter()
            FetchSomeFilm.shared.fetchGenres() { genres in
                completion(genres)
                self.group.leave()
            }
        }
    }
    
    private func fetchAllPlatforms() {
        let platformsUrl = "https://api.rawg.io/api/platforms?key=7f01c67ed4d2433bb82f3dd38282088c&page=1"
        
        queue.async(group: group) { [unowned self] in
            group.enter()
            FetchSomeFilm.shared.fetchAllPlatforms(with: platformsUrl) {
                self.group.leave()
            }
        }
    }
    
    private func setupVC() {
        
        let mainTableVC = MainTableViewController()
        let publishersVC = MainTableViewController()
        
        fetchGameModel { viewModel in
            mainTableVC.viewModel = viewModel
        }
        
        fetchPublishersViewModel { viewModel in
            publishersVC.viewModel = viewModel
        }
        
        fetchGenresForApp() { genres in
            GlobalProperties.shared.genres = Observable(genres)
        }
        
        fetchAllPlatforms()
        
        group.notify(queue: .main) { [unowned self] in
            let searchViewController = SearchScreenViewController()
            let searchViewControllerViewModel = SearchScreenViewModel()
            searchViewController.viewModel = searchViewControllerViewModel
            
            viewControllers = [
                addNavBar(for: mainTableVC, title: "Games", image: UIImage(systemName: "gamecontroller")!),
                addNavBar(for: publishersVC, title: "Publishers", image: UIImage(systemName: "tortoise")!),
                addNavBar(for: searchViewController, title: "Search", image: UIImage(systemName: "magnifyingglass")!)
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
        
        
        
        navigationController.navigationBar.layer.shadowPath = UIBezierPath(roundedRect: navigationController.navigationBar.bounds, cornerRadius: 2).cgPath
        navigationController.navigationBar.layer.shadowColor = UIColor.black.cgColor
        navigationController.navigationBar.layer.shadowRadius = 5
        navigationController.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 4)
        navigationController.navigationBar.layer.shadowOpacity = 0.6
        
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
        
        tabBar.layer.shadowPath = UIBezierPath(roundedRect: tabBar.bounds, cornerRadius: 2).cgPath
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowRadius = 3.5
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
        tabBar.layer.shadowOpacity = 0.45
        
        tabBar.standardAppearance = appearence
        tabBar.scrollEdgeAppearance = appearence
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
        fetchGenresForApp() { genres in
            completionTwo(genres)
        }
    }
}
#endif

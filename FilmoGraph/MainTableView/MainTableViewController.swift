//
//  ViewController.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 14/06/2022.
//

import UIKit

protocol StopLoadingPic {
    func stopWith(uuid: UUID?)
}

class MainTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        indicator.startAnimating()
        viewModel.games.bind { [ unowned self ] _ in
            self.viewModel.updateSearchResults(text: text) { [ unowned self ] in
                DispatchQueue.main.async {
                    indicator.stopAnimating()
                    tableView.reloadData()
                }
            }
        }
    }
    
    let viewModel = MainTableViewModel()
    let searchController = UISearchController(searchResultsController: nil)
    
    let indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNavBar()
        createTableView()
        createSearchBar()
        
        viewModel.games.bind { [unowned self] _ in
            viewModel.fetchGames() {
                DispatchQueue.main.async {
                    indicator.stopAnimating()
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension MainTableViewController {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let url = viewModel.cellDidTap(indexPath)
        let detailsVC = DetailGameViewController()
        detailsVC.delegate = self
        viewModel.createDetailViewControllerModel(with: url) { gameDetails in
            detailsVC.viewModel = DetailGameViewModel(game: gameDetails)
        }
        
        show(detailsVC, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.games.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell
    
        cell.viewModel = viewModel.cellForRowAt(indexPath)
        cell.prepareForReuse()
        cell.awakeFromNib()
        
        return cell
    }
}

extension MainTableViewController {
    func createTableView() {
        let tableView = UITableView()
        
        tableView.sizeToFit()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 220
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        tableView.addSubview(indicator)
        
        tableView.register(Cell.self, forCellReuseIdentifier: "Cell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        indicator.startAnimating()
        self.tableView = tableView
    }
    
    func createSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Find game"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}

extension MainTableViewController {
    
    private func addNavBar() {
        title = "Some games"
        let navbarapp = UINavigationBarAppearance()
        
        navbarapp.backgroundColor = UIColor(red: 65/255, green: 144/255, blue: 255/255, alpha: 1)
        navbarapp.titleTextAttributes = [.foregroundColor: UIColor.white]
        navbarapp.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Find game", style: .plain, target: self, action:  #selector(pressedRightBottom))
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = navbarapp
        navigationController?.navigationBar.scrollEdgeAppearance = navbarapp
        
    }
    
    @objc private func pressedRightBottom() {
        print("Click")
        
    }
}

extension MainTableViewController: StopLoadingPic {
    func stopWith(uuid: UUID?) {
        guard let uuid = uuid else { return }
        URLResquests.shared.runningRequests[uuid]?.cancel()
        print("stopped")
        URLResquests.shared.runningRequests.removeValue(forKey: uuid)
    }
}


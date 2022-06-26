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

final class MainTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        indicator.startAnimating()
        viewModel.games.bind { [ unowned self ] _ in
            self.viewModel.updateSearchResults(text: text) {
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private let viewModel = MainTableViewModel()
    private var searchController: UISearchController!
    private var currentPage = 1
    
    private let indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNavBar()
        createSearchBar()
        
        createTableView()
        
        viewModel.games.bind { [unowned self] _ in
            fetchGames()
        }
    }
}

//MARK: TableViewDelegate
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
        return viewModel.games.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell
        
        cell.viewModel = viewModel.cellForRowAt(indexPath)
        cell.prepareForReuse()
        cell.awakeFromNib()
        
        return cell
    }
}

//MARK: UI Methods
extension MainTableViewController {
    private func createTableView() {
        let tableView = UITableView()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.sizeToFit()
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
    
    private func createSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Find game"
        searchController.searchBar.searchTextField.backgroundColor = UIColor(white: 1, alpha: 0.7)
        definesPresentationContext = true
        
        let textField = searchController.searchBar.searchTextField
        let searchBar = searchController.searchBar
        
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        navigationItem.searchController = searchController
        
        
        navigationItem.searchController?.searchBar.translatesAutoresizingMaskIntoConstraints = false
        guard let navSearch = navigationItem.searchController?.searchBar else { return }
        
        NSLayoutConstraint.activate([
            searchBar.widthAnchor.constraint(equalTo: navSearch.widthAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: navSearch.bounds.height * 0.8)
        ])
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor, constant: 16),
            textField.centerYAnchor.constraint(equalTo: navSearch.centerYAnchor),
            textField.widthAnchor.constraint(equalToConstant: navSearch.frame.width * 0.75),
            textField.heightAnchor.constraint(equalTo: navSearch.heightAnchor)
        ])
        
        self.searchController = searchController
        navigationItem.searchController = self.searchController
        
    }
}

//MARK: Bottom methods
extension MainTableViewController {
    
    private func addNavBar() {
        title = "Some games"
        let navbarapp = UINavigationBarAppearance()
        
        navbarapp.backgroundColor = UIColor(red: 65/255, green: 144/255, blue: 255/255, alpha: 1)
        navbarapp.titleTextAttributes = [.foregroundColor: UIColor.white]
        navbarapp.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Next page \u{203A}",
            style: .plain,
            target: self,
            action: #selector(nextPageBottom))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "\u{2039} Pervous page",
            style: .plain,
            target: self,
            action: #selector(pervPageBottom))
        
        navigationItem.leftBarButtonItem?.isEnabled = false
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = navbarapp
        navigationController?.navigationBar.scrollEdgeAppearance = navbarapp
        
    }
    
    @objc private func nextPageBottom() {
        indicator.startAnimating()
        currentPage += 1
        navigationItem.leftBarButtonItem?.isEnabled = true
        fetchGames(with: viewModel.nextPage)
        viewModel.nextPage != nil ? (navigationItem.rightBarButtonItem?.isEnabled = true) : (navigationItem.rightBarButtonItem?.isEnabled = false)
    }
    
    @objc private func pervPageBottom() {
        indicator.startAnimating()
        currentPage -= 1
        navigationItem.rightBarButtonItem?.isEnabled = true
        fetchGames(with: viewModel.prevPage)
        viewModel.prevPage != nil
        ? (navigationItem.leftBarButtonItem?.isEnabled = true)
        : (navigationItem.leftBarButtonItem?.isEnabled = false)
    }
}


//MARK: Additional methods
extension MainTableViewController {
    
    private func checkButtonsConditions() {
        viewModel.nextPage != nil ? (navigationItem.rightBarButtonItem?.isEnabled = true) : (navigationItem.rightBarButtonItem?.isEnabled = false)
        viewModel.prevPage != nil ? (navigationItem.leftBarButtonItem?.isEnabled = true) : (navigationItem.leftBarButtonItem?.isEnabled = false)
    }
    
    private func fetchGames(with url: String? = nil) {
        
        var urlString: String?
        
        if let url = url {
            urlString = url
        }
        
        
        viewModel.games = Observable([])
        tableView.reloadData()
        
        viewModel.fetchGamesWith(page: viewModel.currentPage, orUrl: urlString) { [unowned self] in
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                self.tableView.reloadData()
            }
        }
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


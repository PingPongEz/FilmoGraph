//
//  ViewController.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 14/06/2022.
//

import UIKit

protocol StopLoadingPic {
    func stopRequestsOnDisappear()
}

final class MainTableViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchResultsUpdating, UICollectionViewDelegateFlowLayout {
    
    
    private let viewModel = MainTableViewModel()
    private var searchController: UISearchController?
    
    private var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        
        layout.sectionInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        
        
        let collectionView = UICollectionView(
            frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height),
            collectionViewLayout: layout
        )
        
        collectionView.register(Cell.self, forCellWithReuseIdentifier: "Cell")
        return collectionView
    }()
    
    private let indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createTableView()
        
        viewModel.games.bind { [unowned self] _ in
            fetchGames()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.isShowAvailable = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        viewModel.searchText = text
        indicator.startAnimating()
        viewModel.games.bind { [ unowned self ] _ in
            self.viewModel.fetchGamesWith(page: 1) {
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

//MARK: FlowLayoutDelegate
extension MainTableViewController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: UIScreen.main.bounds.width * 0.9, height: 220)
    }
    
    func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
        let layout = UICollectionViewFlowLayout()
        
        layout.sectionInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width * 0.9, height: 220)
        let layout2 = UICollectionViewFlowLayout()
        
        layout2.sectionInset = UIEdgeInsets(top: 40, left: 32, bottom: 40, right: 32)
        layout2.itemSize = CGSize(width: UIScreen.main.bounds.width * 0.9, height: 500)
        
        return UICollectionViewTransitionLayout(currentLayout: layout, nextLayout: layout2)
    }
}

//MARK: TableViewDelegate
extension MainTableViewController {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.games.value.count
    }
    
    //MARK: CellForItemAt
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Cell
        
        cell.viewModel = viewModel.cellForRowAt(indexPath)
        cell.awakeFromNib()
        cell.prepareForReuse()
        
        return cell
    }
    
    //MARK: Did Select Row
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
        if viewModel.isShowAvailable {
            viewModel.isShowAvailable = false
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [unowned self] _ in
                
                weak var detailVC = viewModel.downloadEveryThingForDetails(with: indexPath)
                
                detailVC?.delegate = self
                
                show(detailVC!, sender: nil)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}

//MARK: UI Methods
extension MainTableViewController {
    private func createTableView() {
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.sizeToFit()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        collectionView.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        indicator.startAnimating()
        
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
    }
}

//MARK: Bottom methods
extension MainTableViewController {
    
    @objc private func nextPageBottom() {
        indicator.startAnimating()
        viewModel.deleteOneRequest()
        
        viewModel.currentPage += 1
        
        navigationItem.leftBarButtonItem?.isEnabled = true
        fetchGames(with: viewModel.nextPage)
        viewModel.nextPage != nil ? (navigationItem.rightBarButtonItem?.isEnabled = true) : (navigationItem.rightBarButtonItem?.isEnabled = false)
    }
    
    
    @objc private func pervPageBottom() {
        indicator.startAnimating()
        viewModel.deleteOneRequest()
        
        viewModel.currentPage -= 1
        
        navigationItem.rightBarButtonItem?.isEnabled = true
        fetchGames(with: viewModel.prevPage)
        viewModel.prevPage != nil ? (navigationItem.leftBarButtonItem?.isEnabled = true) : (navigationItem.leftBarButtonItem?.isEnabled = false)
    }
}


//MARK: Additional methods
extension MainTableViewController {
    
    private func fetchGames(with url: String? = nil) {
        
        var urlString: String?
        
        if let url = url {
            urlString = url
        }
        
        viewModel.games = Observable([])
        collectionView.reloadData()
        
        viewModel.fetchGamesWith(page: viewModel.currentPage, orUrl: urlString) {
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                self.collectionView.reloadData()
            }
        }
    }
}

extension MainTableViewController: StopLoadingPic {
    func stopRequestsOnDisappear() {
        viewModel.deleteRequests()
        print(URLResquests.shared.runningRequests.count)
    }
}


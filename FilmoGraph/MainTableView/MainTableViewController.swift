//
//  ViewController.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 14/06/2022.
//

import UIKit

protocol StopLoadingPic {
    func actionsWhileDetailViewControllerDisappears()
}

final class MainTableViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate {
    
    let arrow = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 28))
    var viewModel: MainTableViewModelProtocol!
    
    lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        
        layout.itemSize = CGSize(width: view.bounds.width * 0.9, height: (view.bounds.width) * 0.55)
        layout.sectionInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        
        return layout
    }()
    
    lazy var collectionView: UICollectionView = {
        
        let collectionView = UICollectionView(
            frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height),
            collectionViewLayout: layout
        )
        
        collectionView.setCollectionViewLayout(layout, animated: true)
        
        collectionView.register(Cell.self, forCellWithReuseIdentifier: "Cell")
        return collectionView
    }()
    
    private var isRotateEnabaled = false
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createTableView()
        
        switch viewModel.mainViewControllerState {              //Setting buttons for NavBar only for All games
        case .games:
            setNavBarButtons()
        default: break
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.isShowAvailable = true                        //Unlocking "show" method
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetLayout()
        DispatchQueue.main.asyncAfter(deadline: .now()) { [unowned self] in
            calculateShadowsOfBars()
            collectionView.reloadData()
            blickCollectionViewAnimation()
            isRotateEnabaled = true                                 //That needs to update only one with viewWillTransition()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isRotateEnabaled = false                                //That needs to update only one with viewWillTransition()
        //If the view invisible it's not updating
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if isRotateEnabaled {                                   //Lock another views here
            DispatchQueue.main.asyncAfter(deadline: .now()) { [unowned self] in
                resetLayout()
                collectionView.reloadData()
                calculateShadowsOfBars()
            }
        }
    }
}

//MARK: Additional methods
extension MainTableViewController {
    private func blickCollectionViewAnimation() {                                   //Blick animation for not to see reloadData() :D
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut) { [weak self] in
            guard let self = self else { return }
            self.collectionView.layer.opacity = 0
        }
        UIView.animate(withDuration: 0.15, delay: 0.15, options: .curveEaseIn) { [weak self] in
            guard let self = self else { return }
            self.collectionView.layer.opacity = 1
        }
    }
    
    private func resetLayout() {                                                    //Setting item's size before rotate
        let width = view.bounds.width
        if UIDevice.current.orientation.isLandscape {
            layout.itemSize = CGSize(width: width * 0.9, height: (width) * 0.35)
        } else if UIDevice.current.orientation.isPortrait {
            layout.itemSize = CGSize(width: width * 0.9, height: (width) * 0.55)
        }
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
        
        DispatchQueue(label: "Cell queue", qos: .userInteractive, attributes: .concurrent).async {
            cell.viewModel = self.viewModel.cellForRowAt(indexPath)
        }
        
        cell.setShadow()                                                            //Setting shadows for each cell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == viewModel.games.value.count - 2 {                      //Adding cells when table view's content almost ended
            if viewModel.nextPage != nil {
                switch viewModel.mainViewControllerState {
                case .games:
                    viewModel.searchFetch { items in
                        collectionView.insertItems(at: items)
                    }
                case .search:
                    viewModel.fetchGamesWith { items in
                        collectionView.insertItems(at: items)
                    }
                case .publishers:
                    viewModel.fetchPublishers { items in
                        collectionView.insertItems(at: items)
                    }
                }
            }
        }
    }
    
    //MARK: Did Select Row
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
        
        if viewModel.isShowAvailable {
            switch viewModel.mainViewControllerState {
            case .games:
                viewModel.isShowAvailable = false
                Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
                    guard let self = self else { return }
                    weak var detailsVC = self.viewModel.downloadEveryThingForDetails(with: indexPath)
                    
                    detailsVC?.delegate = self
                    guard let detailsVC = detailsVC else { return }
                    
                    self.show(detailsVC, sender: nil)
                }
            case .publishers:
                print("Publisher segue")
            default:
                viewModel.isShowAvailable = false
                Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
                    guard let self = self else { return }
                    weak var detailsVC = self.viewModel.downloadEveryThingForDetails(with: indexPath)
                    
                    detailsVC?.delegate = self
                    guard let detailsVC = detailsVC else { return }
                    
                    self.show(detailsVC, sender: nil)
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        calculateShadowsOfBars()
    }
}

//MARK: UI Methods
extension MainTableViewController {
    private func createTableView() {
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        collectionView.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        
    }
}

//MARK: Setting CollectionViewBar
extension MainTableViewController {
    private func setNavBarButtons() {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sort by: \(viewModel.ordering.rawValue.capitalized)", style: .done, target: self, action: #selector(chooseSortMethod))
        
        arrow.image = UIImage(systemName: "arrow.down.square")
        arrow.isHidden = false
        arrow.layer.opacity = 1
        arrow.tintColor = .white
        arrow.isUserInteractionEnabled = true
        arrow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chooseSortRevercing)))
        
        let item = UIBarButtonItem(customView: arrow)
        
        navigationItem.rightBarButtonItem = item
    }
    
    @objc private func chooseSortMethod() {
        
        // Action for each button in sheet. startAction made for fetching after pressing on button but not at leftBarButton
        
        let actionSheet = viewModel.createAlertController(
            startAction: { [unowned self] in preFetchReload()} ) { [weak self] items in
                guard let self = self else { return }
                self.loadingIndicator.stopAnimating()
                self.collectionView.reloadItems(at: items)
                self.navigationItem.leftBarButtonItem?.title = "Sort by: \(self.viewModel.ordering.rawValue.capitalized)"
            }
        
        present(actionSheet, animated: true)
    }
    
    @objc private func chooseSortRevercing() {
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            if self.viewModel.isReversed.value {
                self.navigationItem.rightBarButtonItem?.customView?.transform = CGAffineTransform(rotationAngle: .pi)
            } else {
                self.navigationItem.rightBarButtonItem?.customView?.transform = CGAffineTransform(rotationAngle: -0)
            }
            self.view.layoutIfNeeded()
        }
        
        //startAction need for reload olny when reverseSorting starts in viewModel
        
        viewModel.reverseSorting(
            startAction: { [weak self] in self?.preFetchReload() }) { [weak self] items in
                guard let self = self else { return }
                self.loadingIndicator.stopAnimating()
                self.collectionView.reloadItems(at: items)
            }
    }
    
    private func preFetchReload() {
        loadingIndicator.startAnimating()
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        collectionView.reloadData()
    }
    
    private func calculateShadowsOfBars() {
        GlobalProperties.shared.setNavBarShadow(navigationController ?? UINavigationController(), tabBarController ?? UITabBarController())
    }
}



extension MainTableViewController: StopLoadingPic {
    func actionsWhileDetailViewControllerDisappears() {
        viewModel.deleteRequests()
    }
}


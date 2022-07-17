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

final class MainTableViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let arrow = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 28))
    var viewModel: MainTableViewModelProtocol!
    
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
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createTableView()
        collectionView.reloadData()
        
        switch viewModel.mainViewControllerState {
        case .games:
            setNavBarButtons()
        default: break
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.isShowAvailable = true
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
        
        DispatchQueue(label: "Cell queue", qos: .userInteractive, attributes: .concurrent).async {
            cell.viewModel = self.viewModel.cellForRowAt(indexPath)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == viewModel.games.value.count - 1 {
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
                Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [unowned self] _ in
                    
                    weak var detailsVC = viewModel.downloadEveryThingForDetails(with: indexPath)
                    
                    detailsVC?.delegate = self
                    guard let detailsVC = detailsVC else { return }
                    
                    show(detailsVC, sender: nil)
                }
            case .publishers:
                print("Publisher segue")
            default:
                viewModel.isShowAvailable = false
                Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [unowned self] _ in
                    
                    weak var detailsVC = viewModel.downloadEveryThingForDetails(with: indexPath)
                    
                    detailsVC?.delegate = self
                    guard let detailsVC = detailsVC else { return }
                    
                    show(detailsVC, sender: nil)
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        GlobalProperties.shared.shadowOnScrolling(navigationController?.navigationBar)
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
        collectionView.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
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
            startAction: { [unowned self] in preFetchReload()} ) { [unowned self] items in
                
                loadingIndicator.stopAnimating()
                collectionView.reloadItems(at: items)
                navigationItem.leftBarButtonItem?.title = "Sort by: \(viewModel.ordering.rawValue.capitalized)"
            }
        
        present(actionSheet, animated: true)
    }
    
    @objc private func chooseSortRevercing() {
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut) { [unowned self] in
            if viewModel.isReversed.value {
                navigationItem.rightBarButtonItem?.customView?.transform = CGAffineTransform(rotationAngle: .pi)
            } else {
                navigationItem.rightBarButtonItem?.customView?.transform = CGAffineTransform(rotationAngle: -0)
            }
            view.layoutIfNeeded()
        }
        
        //startAction need for reload olny when reverseSorting starts in viewModel
        
        viewModel.reverseSorting(
            startAction: { [unowned self] in preFetchReload() }) { [unowned self] items in
                
                loadingIndicator.stopAnimating()
                collectionView.reloadItems(at: items)
            }
    }
    
    private func preFetchReload() {
        loadingIndicator.startAnimating()
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        collectionView.reloadData()
    }
}



extension MainTableViewController: StopLoadingPic {
    func actionsWhileDetailViewControllerDisappears() {
        viewModel.deleteRequests()
        print(URLResquests.shared.runningRequests.count)
        
    }
}


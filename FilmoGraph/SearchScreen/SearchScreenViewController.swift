//
//  SearchScreenViewController.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 07/07/2022.
//

import UIKit

class SearchScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var viewModel = SearchScreenViewModel()
    
    var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    private lazy var actionForGanre = UIAction(title: "Action", attributes: .disabled, state: .on) { [unowned self] _ in
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn) { [unowned self] in
            viewModel.ganreSelectedButtonPressed()
            view.layoutIfNeeded()
        }
    }
    
    private lazy var actionForPlatform = UIAction(title: "Action", attributes: .disabled, state: .on) { [unowned self] _ in
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn) { [unowned self] in
            viewModel.platformSelectedButtonPressed()
            view.layoutIfNeeded()
        }
    }
    
    private lazy var actionForSearchButton = UIAction(title: "Action", attributes: .disabled, state: .on) { [unowned self] _ in
        loadingIndicator.startAnimating()
        UIView.animate(withDuration: 0.17) {
            self.loadingView.layer.opacity = 0.4
        }
        
        viewModel.findButtonPressed { searchVC in
            self.loadingView.layer.opacity = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.show(searchVC, sender: nil)
            }
        }
    }
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .white
        loadingView.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return indicator
    }()
    
    private lazy var loadingView: UIView = {
        let view = UIView(frame: view.frame)
        
        view.backgroundColor = .black
        view.layer.opacity = 0
        self.view.addSubview(view)
        
        return view
    }()
    
    private lazy var ganreButton: UIButton = {
        let button = UIButton()
        var config: UIButton.Configuration = .bordered()
        
        config.title = viewModel.ganreButtonText
        config.baseBackgroundColor = UIColor(white: 0.7, alpha: 0.8)
        config.titleAlignment = .leading
        config.cornerStyle = .small
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = config
        button.tintColor = .black
        
        return button
        
    }()
    
    private lazy var platformButton: UIButton = {
        let button = UIButton()
        var config: UIButton.Configuration = .bordered()
        
        config.title = viewModel.platformButtonText
        config.baseBackgroundColor = UIColor(white: 0.7, alpha: 0.8)
        config.titleAlignment = .leading
        config.cornerStyle = .small
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = config
        button.tintColor = .black
        
        return button
    }()
    
    private let startSearchButton: UIButton = {
        let button = UIButton()
        var config: UIButton.Configuration = .bordered()
        
        config.title = "Find"
        config.baseBackgroundColor = UIColor.myBlueColor
        config.titleAlignment = .leading
        config.cornerStyle = .small
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = config
        button.tintColor = .white
        
        return button
    }()
    
    private var ganreTableView: UITableView = {
        let tableView = UITableView()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        return tableView
    }()
    
    private var platformTableView: UITableView = {
        let tableView = UITableView()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        return tableView
    }()
    
    //MARK: View Did Load
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = .white
        
        addSubviewsToSuperView(views: [ganreButton, ganreTableView, platformButton, platformTableView, startSearchButton])
        
        setButtonAndTableView(
            withButton: ganreButton,
            andTable: ganreTableView,
            on: 200
        )
        
        setButtonAndTableView(
            withButton: platformButton,
            andTable: platformTableView,
            fromView: ganreButton,
            on: 80 + screenHeight * 0.05
        )
        
        view.insertSubview(ganreTableView, aboveSubview: platformButton)
        view.insertSubview(ganreTableView, aboveSubview: platformTableView)
        
        tableViewSettings(&ganreTableView)
        tableViewSettings(&platformTableView)
        
        setButtonActions()
        setTableViewHeights()
        setSearchButton()
        
        hideTableViewsWhenTappedAround()
        
        GlobalProperties.shared.shadowOnScrolling(navigationController?.navigationBar)
    }
    
    //MARK: Dismiss TableViewes when view tapped
    private func hideTableViewsWhenTappedAround() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissTalbeViews(_:)))
        view.addGestureRecognizer(tap)
        tap.delegate = self
        
    }
    
    @objc private func dismissTalbeViews(_ sender: UITapGestureRecognizer) {
        
        if sender.state == .ended {
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut) { [unowned self] in
                viewModel.dismissTableViews()
                view.layoutIfNeeded()
            }
        }
    }
    
    private func setButtonActions() {
        
        ganreButton.addAction(actionForGanre, for: .touchUpInside)
        platformButton.addAction(actionForPlatform, for: .touchUpInside)
        startSearchButton.addAction(actionForSearchButton, for: .touchUpInside)
        
    }
    
    private func setTableViewHeights() {
        viewModel.ganreHeight = ganreTableView.heightAnchor.constraint(equalToConstant: 0)
        viewModel.ganreHeight?.isActive = true
        
        viewModel.platformHeight = platformTableView.heightAnchor.constraint(equalToConstant: 0)
        viewModel.platformHeight?.isActive = true
        
    }
}
//MARK: UISettings
extension SearchScreenViewController {
    
    private func addSubviewsToSuperView(views: [UIView]) {
        views.forEach { view.addSubview($0) }
    }
    
    private func setButtonAndTableView(withButton button: UIButton, andTable table: UITableView, fromView: UIView? = nil, on constant: CGFloat) {
        
        guard var parentView = self.view else { return }
        
        if let nilView = fromView {
            parentView = nilView
        }
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: parentView.topAnchor, constant: constant),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: screenWidth * 0.8),
            button.heightAnchor.constraint(equalToConstant: screenHeight * 0.05)
        ])
        
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: button.bottomAnchor),
            table.leadingAnchor.constraint(equalTo: button.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: button.trailingAnchor),
            table.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
        ])
        
    }
    
    private func setSearchButton() {
        NSLayoutConstraint.activate([
            startSearchButton.topAnchor.constraint(equalTo: view.topAnchor, constant: screenHeight * 0.8),
            //Почему-то от нижнего анкора не ставится вьюха
            startSearchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startSearchButton.widthAnchor.constraint(equalToConstant: screenWidth * 0.8),
            startSearchButton.heightAnchor.constraint(equalToConstant: screenHeight * 0.05)
        ])
    }
    
    private func tableViewSettings(_ tableView: inout UITableView) {
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.autoresizingMask = UIView.AutoresizingMask.flexibleHeight
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = UIColor.gray.cgColor
        tableView.layer.cornerRadius = 6
        
    }
}

//MARK: TableView methods
extension SearchScreenViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let type = setTableViewType(tableView: tableView)
        
        return viewModel.numberOfRowsInSection(section: section, tableVieewType: type)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = setTableViewType(tableView: tableView)
        
        return viewModel.cellForRowAt(tableView, at: indexPath, tableViewType: type)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let type = setTableViewType(tableView: tableView)
        
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut) { [unowned self] in
            viewModel.didSelectRowAt(indexPath: indexPath, tableViewType: type) { text in
                if type == .genre {
                    self.ganreButton.setTitle(text, for: .normal)
                } else if type == .platform {
                    self.platformButton.setTitle(text, for: .normal)
                }
            }
            view.layoutIfNeeded()
        }
    }
    
    private func setTableViewType(tableView: UITableView) -> TableViewType? {
        var type: TableViewType?
        
        if tableView == ganreTableView {
            type = .genre
        } else if tableView == platformTableView {
            type = .platform
        }
        
        return type
    }
}

//MARK: Gesture delegate
extension SearchScreenViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if (touch.view?.isDescendant(of: ganreTableView) == true) || (touch.view?.isDescendant(of: platformTableView) == true) {
            return false
        }
        return true
        
    }
}

enum TableViewType {
    case genre
    case platform
}

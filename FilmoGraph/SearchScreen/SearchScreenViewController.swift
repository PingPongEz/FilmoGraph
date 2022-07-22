//
//  SearchScreenViewController.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 07/07/2022.
//

import UIKit

final class SearchScreenViewController: UIViewController, UITextFieldDelegate {
    
    var viewModel: SearchScreenViewModelProtocol!
    
    var screenHeight: CGFloat {
        return UIScreen.main.bounds.size.height
    }
    
    var screenWidth: CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    private lazy var actionForGanre = UIAction(title: "Action", attributes: .disabled, state: .on) { [unowned self] _ in
        print(platformButton.constraints)
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
        searchButtonTapped()
    }
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .white
        loadingView.addSubview(indicator)
        
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
        let button = UIButton(frame: .zero)
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
        let button = UIButton(frame: .zero)
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
        let button = UIButton(frame: .zero)
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
    
    private var searchTextField: UITextField = {
        let textField = UITextField()
        
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter game..."
        textField.keyboardType = .default
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.returnKeyType = .search
        
        return textField
    }()
    
    //MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        addSubviewsToSuperView(views: [ganreButton, platformButton, startSearchButton, searchTextField, loadingView])
        
        searchTextField.delegate = self
        view.insertSubview(ganreTableView, aboveSubview: platformButton)
        view.insertSubview(ganreTableView, aboveSubview: platformTableView)
        view.insertSubview(platformTableView, aboveSubview: startSearchButton)
        view.insertSubview(ganreTableView, aboveSubview: startSearchButton)
        
        tableViewSettings(&ganreTableView)
        tableViewSettings(&platformTableView)

        setButtonActions()
        setTableViewHeights()
        setButtonAndTableView()
        
        hideTableViewsWhenTappedAround()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        GlobalProperties.shared.setNavBarShadow(navigationController ?? UINavigationController(), tabBarController ?? UITabBarController())
        setButtonAndTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: Dismiss TableViewes when view tapped
    private func hideTableViewsWhenTappedAround() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissTalbeViews(_:)))
        view.addGestureRecognizer(tap)
        tap.delegate = self
    }
    
    
    private func setButtonActions() {
        
        ganreButton.addAction(actionForGanre, for: .touchUpInside)
        platformButton.addAction(actionForPlatform, for: .touchUpInside)
        startSearchButton.addAction(actionForSearchButton, for: .touchUpInside)
        
    }
    
    private func searchButtonTapped() {
        loadingIndicator.startAnimating()
        UIView.animate(withDuration: 0.17) {
            self.loadingView.layer.opacity = 0.4
        }
        
        viewModel.findButtonPressed { searchVC in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.loadingView.layer.opacity = 0
                self.show(searchVC, sender: nil)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchButtonTapped()
        return true
    }
    
    @objc private func dismissTalbeViews(_ sender: UITapGestureRecognizer) {
        
        view.endEditing(true)
        if sender.state == .ended {
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut) { [unowned self] in
                viewModel.dismissTableViews()
                view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        viewModel.textFieldText = searchTextField.text
    }
}

//MARK: UISettings
extension SearchScreenViewController {
    
    private func addSubviewsToSuperView(views: [UIView]) {
        views.forEach { view.addSubview($0) }
    }
    
    private func setButtonAndTableView() {
        
        view.removeConstraints(view.constraints)
        
        NSLayoutConstraint.activate([
            
            searchTextField.topAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: screenHeight * 0.2),
            searchTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchTextField.heightAnchor.constraint(equalToConstant: 40),
            searchTextField.widthAnchor.constraint(equalToConstant: screenWidth * 0.7),
            
            ganreButton.topAnchor.constraint(lessThanOrEqualTo: searchTextField.bottomAnchor, constant: screenHeight * 0.05),
            ganreButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ganreButton.heightAnchor.constraint(equalToConstant: 40),
            ganreButton.widthAnchor.constraint(equalToConstant: screenWidth * 0.7),
            
            ganreTableView.topAnchor.constraint(equalTo: ganreButton.bottomAnchor),
            ganreTableView.leadingAnchor.constraint(equalTo: ganreButton.leadingAnchor),
            ganreTableView.trailingAnchor.constraint(equalTo: ganreButton.trailingAnchor),
            
            platformButton.topAnchor.constraint(lessThanOrEqualTo: ganreButton.bottomAnchor, constant: screenHeight * 0.05),
            platformButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            platformButton.heightAnchor.constraint(equalToConstant: 40),
            platformButton.widthAnchor.constraint(equalToConstant: screenWidth * 0.7),
            
            platformTableView.topAnchor.constraint(equalTo: platformButton.bottomAnchor),
            platformTableView.leadingAnchor.constraint(equalTo: platformButton.leadingAnchor),
            platformTableView.trailingAnchor.constraint(equalTo: platformButton.trailingAnchor),
            
            startSearchButton.topAnchor.constraint(lessThanOrEqualTo: platformButton.bottomAnchor, constant: screenHeight * 0.05),
            startSearchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startSearchButton.heightAnchor.constraint(equalToConstant: 40),
            startSearchButton.widthAnchor.constraint(equalToConstant: screenWidth * 0.7),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    
    private func setTableViewHeights() {
        
        viewModel.ganreHeight = ganreTableView.heightAnchor.constraint(equalToConstant: 0)
        viewModel.ganreHeight?.isActive = true
        
        viewModel.platformHeight = platformTableView.heightAnchor.constraint(equalToConstant: 0)
        viewModel.platformHeight?.isActive = true
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
extension SearchScreenViewController: UITableViewDelegate, UITableViewDataSource {
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

//
//  SearchScreenViewController.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 07/07/2022.
//

import UIKit

class SearchScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var viewModel = SearchScreenViewModel()
    
    lazy var actionForGanre = UIAction(title: "Action", attributes: .disabled, state: .on) { [unowned self] _ in
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn) { [unowned self] in
            viewModel.isGanreCotainerOpened
            ? (viewModel.ganreHeight?.constant = 0)
            : (viewModel.ganreHeight?.constant = 150)
            view.layoutIfNeeded()
        }
        viewModel.isGanreCotainerOpened.toggle()
    }
    
    lazy var actionForPlatform = UIAction(title: "Action", attributes: .disabled, state: .on) { [unowned self] _ in
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn) { [unowned self] in
            viewModel.iscurrentPlatformOpened
            ? (viewModel.platformHeight?.constant = 0)
            : (viewModel.platformHeight?.constant = 150)
            
            view.layoutIfNeeded()
        }
        viewModel.iscurrentPlatformOpened.toggle()
    }
    
    private let ganreButton: UIButton = {
        let button = UIButton()
        var config: UIButton.Configuration = .bordered()
        
        config.title = "Chose game ganre"
        config.baseBackgroundColor = UIColor(white: 0.7, alpha: 0.8)
        config.titleAlignment = .leading
        config.cornerStyle = .small
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = config
        button.tintColor = .black
        
        return button
        
    }()
    
    private let platformButton: UIButton = {
        let button = UIButton()
        var config: UIButton.Configuration = .bordered()
        
        config.title = "Chose game platform"
        config.baseBackgroundColor = UIColor(white: 0.7, alpha: 0.8)
        config.titleAlignment = .leading
        config.cornerStyle = .small
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = config
        button.tintColor = .black
        
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
    
    //MARK: View did Load
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = .white
        
        addSubviewsToSuperView(views: [ganreButton, ganreTableView, platformButton, platformTableView])
        setButtonAndTableView(withButton: ganreButton, andTable: ganreTableView, on: 200)
        setButtonAndTableView(withButton: platformButton, andTable: platformTableView, fromView: ganreButton, on: 80 + UIScreen.main.bounds.height * 0.05)
        
        view.insertSubview(ganreTableView, aboveSubview: platformButton)
        view.insertSubview(ganreTableView, aboveSubview: platformTableView)
        
        setTableViewGanre(&ganreTableView)
        setTableViewGanre(&platformTableView)
        
        setButtonActions()
        setTableViewHeights()
        
        hideTableViewsWhenTappedAround()
        
    }
    
    //MARK: Dismiss TableViewes when view tapped
    func hideTableViewsWhenTappedAround() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissTalbeViews(_:)))
        view.addGestureRecognizer(tap)
        tap.delegate = self
        
    }
    
    @objc private func dismissTalbeViews(_ sender: UITapGestureRecognizer) {
        
        if sender.state == .ended {
            if sender.view == self.view {
                UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut) { [unowned self] in
                    viewModel.ganreHeight?.constant = 0
                    viewModel.isGanreCotainerOpened = false
                    view.layoutIfNeeded()
                }
                
                UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut) { [unowned self] in
                    viewModel.platformHeight?.constant = 0
                    viewModel.iscurrentPlatformOpened = false
                    view.layoutIfNeeded()
                }
            }
        }
    }

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
            button.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8),
            button.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.05)
        ])
        
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: button.bottomAnchor),
            table.leadingAnchor.constraint(equalTo: button.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: button.trailingAnchor),
            table.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
        ])
        
    }
    
    private func setTableViewGanre(_ tableView: inout UITableView) {
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.autoresizingMask = UIView.AutoresizingMask.flexibleHeight
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = UIColor.gray.cgColor
        tableView.layer.cornerRadius = 6
        
    }
    
    private func setButtonActions() {
        
        ganreButton.addAction(actionForGanre, for: .touchUpInside)
        platformButton.addAction(actionForPlatform, for: .touchUpInside)
    }
    
    private func setTableViewHeights() {
        viewModel.ganreHeight = ganreTableView.heightAnchor.constraint(equalToConstant: 0)
        viewModel.ganreHeight?.isActive = true
        
        viewModel.platformHeight = platformTableView.heightAnchor.constraint(equalToConstant: 0)
        viewModel.platformHeight?.isActive = true
    }
}

//MARK: TableView methods
extension SearchScreenViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == ganreTableView {
            return GlobalProperties.shared.genres?.value.count ?? 0
        } else if tableView == platformTableView {
            return GlobalProperties.shared.platforms.value.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        
        if tableView == ganreTableView {
            let ganre = GlobalProperties.shared.genres?.value.results?[indexPath.row]
            content.text = ganre?.name
        } else if tableView == platformTableView {
            let platform = GlobalProperties.shared.platforms.value[indexPath.row]
            content.text = platform.name
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == ganreTableView {
            let ganreContent = GlobalProperties.shared.genres?.value.results?[indexPath.row]
            ganreButton.setTitle(ganreContent?.name, for: .normal)
            
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut) { [unowned self] in
                viewModel.isGanreCotainerOpened = false
                viewModel.ganreHeight?.constant = 0
                view.layoutIfNeeded()
            }
            
        } else if tableView == platformTableView {
            let platform = GlobalProperties.shared.platforms.value[indexPath.row]
            platformButton.setTitle(platform.name, for: .normal)
            
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut) { [unowned self] in
                viewModel.iscurrentPlatformOpened = false
                viewModel.platformHeight?.constant = 0
                view.layoutIfNeeded()
            }
        }
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

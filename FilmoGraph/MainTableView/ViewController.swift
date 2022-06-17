//
//  ViewController.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 14/06/2022.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var viewModel = MainTableViewModel()
    
    private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemMint
        createTableView()
        
        viewModel.games.bind { [unowned self] _ in
            viewModel.fetchGames() {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension ViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if viewModel.games.value.isEmpty {
            let cell = LoadingCell()
            cell.awakeFromNib()
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell
    
        cell.viewModel = viewModel.cellForRowAt(indexPath)
        cell.prepareForReuse()
        cell.awakeFromNib()
        
        return cell
    }
}

extension ViewController {
    func createTableView() {
        let tableView = UITableView()
        
        tableView.sizeToFit()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 110
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        
        tableView.register(Cell.self, forCellReuseIdentifier: "Cell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        
        self.tableView = tableView
    }
}

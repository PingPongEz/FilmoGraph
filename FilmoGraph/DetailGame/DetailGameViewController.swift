//
//  DetailAboutGame.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 19/06/2022.
//

import UIKit

class DetailGameViewController: UIViewController {
    
    var urlForFetch: String!
    
    private let gameName = UILabel()
    private let gameDescription = UILabel()
    private let gamePicture = UIImageView()
    private let gamePlatforms = UILabel()
    private let gameRate = UILabel()
    
    private let indicator = UIActivityIndicatorView()
    
    var viewModel: DetailGameViewModelProtocol? {
        didSet {
            guard let viewModel = viewModel else { return }
            viewModel.gamePicture.bind { [unowned self] image in
                indicator.stopAnimating()
                gamePicture.image = image
            }
            gameName.text = viewModel.gameName
            gameDescription.text = viewModel.gameDescription
            gamePlatforms.text = viewModel.gamePlatforms
            gameRate.text = viewModel.gameRate
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        addIndicator()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createDetailViewControllerModel()
    }
    
    func createDetailViewControllerModel() {
        var gameDetailsViewModel: Observable<GameDetais>?
        DispatchQueue.global().async { [unowned self] in
            FetchSomeFilm.shared.fetchGameDetails(with: urlForFetch) { result in
                do {
                    let details = try result.get()
                    gameDetailsViewModel?.value = details
                } catch {
                    print(error)
                }
            }
        }
        self.viewModel = DetailGameViewModel(game: gameDetailsViewModel)
    }
}




//MARK: UI setings
extension DetailGameViewController {
    private func addIndicator() {
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        indicator.hidesWhenStopped = true
        indicator.isHidden = false
        
        view.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func addAllOthers() {
        
    }
}

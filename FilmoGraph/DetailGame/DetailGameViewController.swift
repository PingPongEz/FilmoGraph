//
//  DetailAboutGame.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 19/06/2022.
//

import UIKit


class DetailGameViewController: UIViewController {
    
    lazy var gesture = UITapGestureRecognizer(target: self, action: #selector(self.tapped(_:)))
    var urlForFetch: String!
    
    var delegate: StopLoadingPic!
    
    private let smallScreenConstraint = min(UIScreen.main.bounds.width * 0.25, UIScreen.main.bounds.height * 0.25)
    private let largeScreenConstraint = min(UIScreen.main.bounds.width * 0.75, UIScreen.main.bounds.height * 0.75)
    
    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()
    
    private let gameName = UILabel()
    
    private let gameDescription: UILabel = {
        let title = UILabel()
        title.numberOfLines = 1
        title.textColor = .gray
        return title
    }()
    
    private let gamePicture = UIImageView()
    private let gamePlatforms: UILabel = {
        let title = UILabel()
        title.numberOfLines = 0
        return title
    }()
    
    private let gameRate = UILabel()
    private let indicator = UIActivityIndicatorView()
    
    var viewModel: DetailGameViewModel? {
        didSet {
            indicator.stopAnimating()
            guard let viewModel = viewModel else { return }
            viewModel.gamePicture.bind { image in
                self.gamePicture.image = image
            }
            gameName.text = viewModel.gameName
            gameDescription.text = "About game : \(viewModel.gameDescription)"
            gamePlatforms.text = "Available at : \(viewModel.gamePlatforms)"
            gameRate.text = viewModel.gameRate
            
            viewWillLayoutSubviews()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        delegate.stopWith(uuid: viewModel?.currentUUID)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        
        gameDescription.isUserInteractionEnabled = true
        gameDescription.addGestureRecognizer(gesture)
        
        
        addIndicator()
    }
    
    override func viewWillLayoutSubviews() {
        addScrollView()
    }
}

//MARK: UI setings
extension DetailGameViewController {
    private func addIndicator() {
        indicator.startAnimating()
        indicator.hidesWhenStopped = true
        indicator.isHidden = false
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func addAllOthers() {
        
        gamePicture.isHidden = false
        gamePicture.clipsToBounds = true
        gamePicture.contentMode = .scaleToFill
        gamePicture.layer.cornerRadius = 14
        
        gameName.textAlignment = .center
        
        gameDescription.textAlignment = .left
        
        NSLayoutConstraint.activate([
            gamePicture.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gamePicture.heightAnchor.constraint(equalToConstant: largeScreenConstraint),
            gamePicture.widthAnchor.constraint(equalToConstant: largeScreenConstraint),
            gamePicture.topAnchor.constraint(equalTo: contentView.topAnchor, constant: smallScreenConstraint / 2)
        ])
        
        NSLayoutConstraint.activate([
            gameName.topAnchor.constraint(equalTo: gamePicture.bottomAnchor, constant: smallScreenConstraint / 2),
            gameName.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
        
        NSLayoutConstraint.activate([
            gameDescription.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 32),
            gameDescription.topAnchor.constraint(equalTo: gameName.bottomAnchor, constant: (smallScreenConstraint / 2) * 0.5),
            gameDescription.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            gamePlatforms.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 32),
            gamePlatforms.topAnchor.constraint(equalTo: gameDescription.bottomAnchor, constant: (smallScreenConstraint / 2) * 0.5),
            gamePlatforms.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    @objc private func tapped(_ sender: UITapGestureRecognizer) {
        if gesture.state == .ended {
            if gameDescription.numberOfLines == 0 {
                gameDescription.numberOfLines = 1
                gameDescription.textColor = .gray
            } else {
                gameDescription.numberOfLines = 0
                gameDescription.textColor = .black
            }
            viewWillLayoutSubviews()
        }
    }
    
    private func addScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.isUserInteractionEnabled = true
        scrollView.isScrollEnabled = true
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
        
        scrollView.contentSize = CGSize(width: view.frame.width, height: 1000)
        
        addSubViews([gameName, gameDescription, gamePlatforms, gameRate, gamePicture])
        
        addAllOthers()
    }
    
    private func addSubViews(_ views: [UIView]) {
        views.forEach { [unowned self] subView in
            subView.translatesAutoresizingMaskIntoConstraints = false
            //            view.insertSubview(subView, aboveSubview: view)
            scrollView.insertSubview(subView, belowSubview: contentView)
        }
    }
}

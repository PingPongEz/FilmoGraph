//
//  DetailAboutGame.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 19/06/2022.
//

import UIKit


final class DetailGameViewController: UIViewController {
    
    var urlForFetch: String!
    
    var delegate: StopLoadingPic!
    
    private let fullScreenConstraint = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    private let smallScreenConstraint = min(UIScreen.main.bounds.width * 0.25, UIScreen.main.bounds.height * 0.25)
    private let largeScreenConstraint = min(UIScreen.main.bounds.width * 0.75, UIScreen.main.bounds.height * 0.75)
    
    private let gameName = UILabel()
    
    private let gameDescription: UILabel = {
        let title = UILabel()
        title.numberOfLines = 1
        title.textColor = .gray
        return title
    }()
    
    private let gamePlatforms: UILabel = {
        let title = UILabel()
        title.numberOfLines = 0
        return title
    }()
    
    
    private lazy var gameRate = UILabel()
    private lazy var indicator = UIActivityIndicatorView()
    private lazy var gesture = UITapGestureRecognizer(target: self, action: #selector(self.tapped(_:)))
    private lazy var pageControll = UIPageControl()
    private lazy var picturePages = UIScrollView()
    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()
    
    
    var viewModel: DetailGameViewModel? {
        didSet {
            indicator.stopAnimating()
            guard let viewModel = viewModel else { return }
            
            gameName.text = viewModel.gameName
            gameDescription.text = "About game : \(viewModel.gameDescription)"
            gamePlatforms.text = "Available at : \(viewModel.gamePlatforms)"
            gameRate.text = viewModel.gameRate
            
            viewModel.fetchScreenShots { [unowned self] in
                DispatchQueue.main.async {
                    self.picturePages.contentSize = CGSize(
                        width: self.fullScreenConstraint * CGFloat(viewModel.images.count),
                        height: self.fullScreenConstraint
                    )
                    self.setImageForScrollView()
                    
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        delegate.stopWith(requests: viewModel?.listOfRequests ?? [])
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
        
        gameName.textAlignment = .center
        picturePages.isPagingEnabled = true
        gameDescription.textAlignment = .left
        
        NSLayoutConstraint.activate([
            picturePages.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            picturePages.heightAnchor.constraint(equalToConstant: fullScreenConstraint),
            picturePages.widthAnchor.constraint(equalToConstant: fullScreenConstraint),
            picturePages.topAnchor.constraint(equalTo: contentView.topAnchor, constant: smallScreenConstraint / 2),
        ])
        
        NSLayoutConstraint.activate([
            gameName.topAnchor.constraint(equalTo: picturePages.bottomAnchor, constant: smallScreenConstraint / 2),
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
        }
    }
    
    private func setImageForScrollView() {
        
        var position: CGFloat = 0
        
        viewModel?.images.forEach { image in
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            imageView.frame = CGRect(x: 0, y: 0, width: fullScreenConstraint, height: fullScreenConstraint)
            
            picturePages.addSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: fullScreenConstraint),
                imageView.heightAnchor.constraint(equalToConstant: fullScreenConstraint),
                imageView.centerYAnchor.constraint(equalTo: picturePages.centerYAnchor),
                imageView.leadingAnchor.constraint(equalTo: picturePages.leadingAnchor, constant: fullScreenConstraint * position)
            ])
            
            position += 1
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
        
        addSubViews([pageControll, gameName, gameDescription, gamePlatforms, gameRate, picturePages])
        
        addAllOthers()
    }
    
    private func addSubViews(_ views: [UIView]) {
        views.forEach { [unowned self] subView in
            subView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.insertSubview(subView, belowSubview: contentView)
        }
    }
}

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
    
    
    private var gameDescription: UILabel = {
        let title = UILabel()
        title.numberOfLines = 1
        title.textColor = .gray
        return title
    }()
    
    private var gamePlatforms: UILabel = {
        let title = UILabel()
        title.numberOfLines = 0
        return title
    }()
    
    private var gameName = UILabel()
    private var gameRate = UILabel()
    private var indicator = UIActivityIndicatorView()
    private var picturePages = UIScrollView()
    private var scrollView = UIScrollView()
    private lazy var gesture = UITapGestureRecognizer(target: self, action: #selector(self.tapped(_:)))
    
    
    var viewModel: DetailGameViewModel?
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate.stopWith(requests: viewModel?.listOfRequests ?? [])
        viewModel = nil
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        
        gameDescription.isUserInteractionEnabled = true
        gameDescription.addGestureRecognizer(gesture)
        
        
        view.addSubview(scrollView)
        
        addIndicator()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        addSubViews([gameName, gameDescription, gameRate, picturePages, gamePlatforms])
        addScrollView()
        calculateHeight()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
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
    
    @objc private func tapped(_ sender: UITapGestureRecognizer) {
        if gesture.state == .ended {
            if gameDescription.numberOfLines == 1 {
                gameDescription.numberOfLines = 0
                gameDescription.textColor = .black
            } else {
                gameDescription.numberOfLines = 1
                gameDescription.textColor = .gray
            }
            uploadUI()
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
        
        scrollView.isUserInteractionEnabled = true
        scrollView.isScrollEnabled = true
        
        
        NSLayoutConstraint.activate([
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        addAllOthers()
    }
    
    private func addAllOthers() {
        
        gameName.textAlignment = .center
        picturePages.isPagingEnabled = true
        gameDescription.textAlignment = .left
        
        NSLayoutConstraint.activate([
            picturePages.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            picturePages.heightAnchor.constraint(equalToConstant: fullScreenConstraint),
            picturePages.widthAnchor.constraint(equalToConstant: fullScreenConstraint),
            picturePages.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: smallScreenConstraint / 2),
        ])
        
        NSLayoutConstraint.activate([
            gameRate.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gameRate.topAnchor.constraint(equalTo: picturePages.bottomAnchor, constant: smallScreenConstraint / 2),
        ])
        
        NSLayoutConstraint.activate([
            gameName.topAnchor.constraint(equalTo: gameRate.bottomAnchor, constant: smallScreenConstraint / 4),
            gameName.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
        ])
        
        NSLayoutConstraint.activate([
            gameDescription.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 32),
            gameDescription.topAnchor.constraint(equalTo: gameName.bottomAnchor, constant: (smallScreenConstraint / 2) * 0.5),
            gameDescription.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            gamePlatforms.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 32),
            gamePlatforms.topAnchor.constraint(equalTo: gameDescription.bottomAnchor, constant: (smallScreenConstraint / 2) * 0.5),
            gamePlatforms.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ])
    }
    
    private func calculateHeight() {
        scrollView.layoutIfNeeded()
        let height = (scrollView.subviews.last?.frame.maxY ?? 0) > (UIScreen.main.bounds.height)
        ? (scrollView.subviews.last?.frame.maxY ?? 0)
        : UIScreen.main.bounds.height
        
        scrollView.contentSize = CGSize(width: view.frame.width, height: height)
        print(scrollView.subviews.last?.frame.maxY)
    }
    
    private func addSubViews(_ views: [UIView]) {
        views.forEach { [unowned self] subView in
            subView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.insertSubview(subView, aboveSubview: scrollView)
        }
    }
    
    func uploadUI() {
        indicator.stopAnimating()
        
        guard let viewModel = viewModel else { return }
        
        gameName.text = viewModel.gameName
        gameDescription.text = "About game : \(viewModel.gameDescription)"
        gamePlatforms.text = "Available at : \(viewModel.gamePlatforms)"
        gameRate.text = viewModel.gameRate
        
        picturePages.contentSize = CGSize(
            width: fullScreenConstraint * CGFloat(viewModel.images.count),
            height: fullScreenConstraint
        )
        setImageForScrollView()
        
        viewWillLayoutSubviews()
    }
}

//
//  Cell.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 15/06/2022.
//

import UIKit

final class Cell: UICollectionViewCell {
    
    var viewModel: CellViewModelProtocol! {
        didSet {
            DispatchQueue.main.async { [unowned self] in
                gameName.text = self.viewModel.gameName
                gameGenre.text = self.viewModel.gameType
                gameCreator.text = self.viewModel.gameCreator
                platform.text = self.viewModel.platform
                
                viewModel.gamePic.bind { image in
                    self.gamePic.image = image
                }
            }
        }
    }
    
    private lazy var gamePic = UIImageView()
    private lazy var stackView = UIStackView()
    private lazy var gameName = UILabel()
    private lazy var gameGenre = UILabel()
    private lazy var platform = UILabel()
    private lazy var gameCreator = UILabel()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel.stopCellRequest()
        gamePic.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.layer.cornerRadius = 13
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.35
        self.layer.shadowRadius = 2
        
        self.layer.shadowOffset = CGSize(width: 2, height: 3)
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 13).cgPath
        self.layer.masksToBounds = false
        self.backgroundColor = .white
        
        setUI()
        setConstr()
        
    }
    
    private func setUI() {
        
        gamePic.translatesAutoresizingMaskIntoConstraints = false
        gamePic.layer.masksToBounds = true
        gamePic.layer.cornerRadius = 16
        
        gameName.translatesAutoresizingMaskIntoConstraints = false
        gameName.font = .systemFont(ofSize: 12)
        gameName.numberOfLines = 0
        
        gameGenre.translatesAutoresizingMaskIntoConstraints = false
        gameGenre.font = .systemFont(ofSize: 12)
        gameGenre.numberOfLines = 0
        
        platform.translatesAutoresizingMaskIntoConstraints = false
        platform.font = .systemFont(ofSize: 12)
        platform.numberOfLines = 0
        
        gameCreator.translatesAutoresizingMaskIntoConstraints = false
        gameCreator.font = .systemFont(ofSize: 12)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(gameName)
        stackView.addArrangedSubview(gameGenre)
        stackView.addArrangedSubview(platform)
        stackView.addArrangedSubview(gameCreator)
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        
        addSubview(gamePic)
        addSubview(stackView)
        
    }
    
    private func setConstr() {
        
        NSLayoutConstraint.activate([
            gamePic.heightAnchor.constraint(equalToConstant: 150),
            gamePic.widthAnchor.constraint(equalToConstant: 150),
            gamePic.centerYAnchor.constraint(equalTo: centerYAnchor),
            gamePic.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
        ])
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: gamePic.trailingAnchor, constant: 10),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

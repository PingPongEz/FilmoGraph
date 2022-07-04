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
            gameName.text = self.viewModel.gameName
            gameType.text = self.viewModel.gameType
            gameCreator.text = self.viewModel.gameCreator
            platform.text = self.viewModel.platform
        }
    }
    
    private var gamePic = UIImageView()
    private var stackView = UIStackView()
    private var gameName = UILabel()
    private var gameType = UILabel()
    private var platform = UILabel()
    private var gameCreator = UILabel()

    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.viewModel.stopCellRequest()
        gamePic.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewModel.gamePic.bind { image in
            DispatchQueue.main.async { [unowned self] in
                gamePic.image = image
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderWidth = 2
        self.layer.borderColor = CGColor(red: 65/255, green: 144/255, blue: 255/255, alpha: 1)
        self.layer.cornerRadius = 13
//        
//        self.layer.shadowColor = self.layer.borderColor
//        self.layer.shadowOffset = CGSize(width: 1, height: 0)
//        self.layer.shadowRadius = 2
//        self.layer.shadowOpacity = 1
        
        clipsToBounds = true
        setUI()
        setConstr()
    }
    
    private func setUI() {
        
        gamePic.translatesAutoresizingMaskIntoConstraints = false
        gamePic.layer.masksToBounds = true
        gamePic.layer.cornerRadius = 16
        
        gameName.translatesAutoresizingMaskIntoConstraints = false
        gameName.font = .systemFont(ofSize: 12)
        
        gameType.translatesAutoresizingMaskIntoConstraints = false
        gameType.font = .systemFont(ofSize: 12)
        
        platform.translatesAutoresizingMaskIntoConstraints = false
        platform.font = .systemFont(ofSize: 12)
        platform.numberOfLines = 0
        
        gameCreator.translatesAutoresizingMaskIntoConstraints = false
        gameCreator.font = .systemFont(ofSize: 12)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(gameName)
        stackView.addArrangedSubview(gameType)
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
//        gamePic.layer.cornerRadius = 13
//        gamePic.layer.shadowOpacity = 1
//        gamePic.layer.shadowColor = UIColor.black.cgColor
//        gamePic.layer.shadowRadius = 3
//        gamePic.layer.shadowOffset = CGSize(width: 5, height: 5)
//
//        gamePic.layer.shadowPath = UIBezierPath(rect: gamePic.bounds).cgPath
//        gamePic.layer.shouldRasterize = true
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: gamePic.trailingAnchor, constant: 10),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
            stackView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

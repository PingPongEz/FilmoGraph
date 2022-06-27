//
//  Cell.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 15/06/2022.
//

import UIKit

class Cell: UITableViewCell {
    
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
        platform.numberOfLines = 2
        
        gameCreator.translatesAutoresizingMaskIntoConstraints = false
        gameCreator.font = .systemFont(ofSize: 12)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        gamePic.layer.cornerRadius = 13
        
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

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
    private let stackView = UIStackView()
    private let gameName = UILabel()
    private let gameType = UILabel()
    private let platform = UILabel()
    private let gameCreator = UILabel()

    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.viewModel.onReuse()
        self.gamePic.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewModel.gamePic.bind { image in
            DispatchQueue.main.async {
                self.gamePic.image = image
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
        gameName.translatesAutoresizingMaskIntoConstraints = false
        gameName.font = .systemFont(ofSize: 12)
        
        gameType.translatesAutoresizingMaskIntoConstraints = false
        gameType.font = .systemFont(ofSize: 12)
        
        platform.translatesAutoresizingMaskIntoConstraints = false
        platform.font = .systemFont(ofSize: 12)
        
        gameCreator.translatesAutoresizingMaskIntoConstraints = false
        gameCreator.font = .systemFont(ofSize: 12)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        gamePic.layer.cornerRadius = 13
        
        stackView.addArrangedSubview(gameName)
        stackView.addArrangedSubview(gameType)
        stackView.addArrangedSubview(platform)
        stackView.addArrangedSubview(gameCreator)
        
        stackView.spacing = 20
        stackView.axis = .vertical
        
        addSubview(gamePic)
        addSubview(stackView)
        
    }
    
    private func setConstr() {
        
        NSLayoutConstraint.activate([
            gamePic.heightAnchor.constraint(equalToConstant: 100),
            gamePic.widthAnchor.constraint(equalToConstant: 100),
            gamePic.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            gamePic.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5)
        ])
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: gamePic.trailingAnchor, constant: 5),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 5),
            stackView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

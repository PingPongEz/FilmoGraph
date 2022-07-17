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
                cellName.text = self.viewModel.cellName
                cellSecondaryName.text = self.viewModel.cellSecondaryName
                cellThirdName.text = self.viewModel.cellThirdName
                
                viewModel.gamePic.bind { image in
                    self.gamePic.image = image
                }
            }
        }
    }
    
    private var gamePic = UIImageView()
    private lazy var stackView = UIStackView()
    private lazy var cellName = UILabel()
    private lazy var cellSecondaryName = UILabel()
    private lazy var cellThirdName = UILabel()
    
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
        
        cellName.translatesAutoresizingMaskIntoConstraints = false
        cellName.font = .systemFont(ofSize: 12)
        cellName.numberOfLines = 0
        
        cellSecondaryName.translatesAutoresizingMaskIntoConstraints = false
        cellSecondaryName.font = .systemFont(ofSize: 12)
        cellSecondaryName.numberOfLines = 0
        
        cellThirdName.translatesAutoresizingMaskIntoConstraints = false
        cellThirdName.font = .systemFont(ofSize: 12)
        cellThirdName.numberOfLines = 0
        
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(cellName)
        stackView.addArrangedSubview(cellSecondaryName)
        stackView.addArrangedSubview(cellThirdName)
        
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        

        
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

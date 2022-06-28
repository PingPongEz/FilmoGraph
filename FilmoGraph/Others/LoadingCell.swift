//
//  LoadingCell.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 17/06/2022.
//

import UIKit

final class LoadingCell: UITableViewCell {

    lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        
        indicator.startAnimating()
        indicator.isHidden = false
        
        return indicator
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setIndicator()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    private func setIndicator() {
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

}

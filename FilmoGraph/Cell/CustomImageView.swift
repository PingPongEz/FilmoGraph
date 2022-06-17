//
//  CustomImageView.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 17/06/2022.
//

import UIKit

class CustomImageView: UIImageView {
    
    let indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        
        indicator.startAnimating()
        indicator.isHidden = false
        
        return indicator
    }()
    
    override var image: UIImage? {
        get {
            return UIImage()
        }
        set {
            if newValue == nil {
                self.isHidden = true
            } else {
                self.image = newValue
            }
        }
    }
}

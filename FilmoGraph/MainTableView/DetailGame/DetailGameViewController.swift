//
//  DetailAboutGame.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 19/06/2022.
//

import UIKit

class DetailGameViewController: UIViewController {
    
    private let gameName = UILabel()
    private let gameDescription = UILabel()
    private let gamePicture = UIImageView()
    private let gamePlatforms = UILabel()
    private let gameRate = UILabel()
    
    
    weak var viewModel: DetailGameViewModelProtocol! {
        willSet {
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}

//MARK: UI setings
extension DetailGameViewController {
    
}

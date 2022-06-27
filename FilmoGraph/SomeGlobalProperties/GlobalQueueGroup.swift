//
//  GlobalQueueGroup.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 26/06/2022.
//

import Foundation

class GlobalGroup {
    private init(){}
    static var shared = GlobalGroup()
    
    let group = DispatchGroup()
}

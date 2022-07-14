//
//  GlobalGroupAndQueue.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 14/07/2022.
//

import Foundation

final class GlobalQueueAndGroup {
    
    private init(){}
    static let shared = GlobalQueueAndGroup()
    
    
    let queue = DispatchQueue(label: "Queue", qos: .default, attributes: .concurrent)
    let group = DispatchGroup()
    
}

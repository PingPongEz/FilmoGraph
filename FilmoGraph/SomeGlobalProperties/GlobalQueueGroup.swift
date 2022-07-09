//
//  GlobalQueueGroup.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 26/06/2022.
//

import Foundation

class GlobalGroup {
    private init(){}
    static let shared = GlobalGroup()
    
    func notifyMe(action: @escaping()-> Void, completeAction: @escaping() -> Void) {
        
        action()
        
        group.notify(queue: .main) {
            completeAction()
        }
        
    }
    
    var group = DispatchGroup()
}

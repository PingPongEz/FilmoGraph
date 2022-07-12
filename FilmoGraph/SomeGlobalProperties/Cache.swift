//
//  Cache.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 11/07/2022.
//

import Foundation
import UIKit

final class Cache {
    
    private init(){}
    
    static let shared = Cache()
    let cache: NSCache<NSString, UIImage> = NSCache()
    private let queue = DispatchQueue(label: "Queue", qos: .utility, attributes: .concurrent, target: .global())
    
    func saveToCache(with url: NSString, and data: Data) {
        queue.async { [unowned self] in
            guard let uiimage = UIImage(data: data) else { return }
            cache.setObject(uiimage, forKey: url)
        }
        
    }
    
    func getFromCache(with url: NSString) -> UIImage? {
        return cache.object(forKey: url)
    }
}

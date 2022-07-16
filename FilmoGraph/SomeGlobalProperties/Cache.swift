//
//  Cache.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 11/07/2022.
//

import Foundation
import UIKit


final class DataCache {
    
    private init(){}
    
    static let shared = DataCache()
    let cache: NSCache<NSString, NSData> = NSCache()
    private let queue = DispatchQueue(label: "Queue", qos: .utility, attributes: .concurrent, target: .global())
    
    func saveToCache(with url: NSString, and data: Data) {
        queue.async { [unowned self] in
            cache.setObject(NSData(data: data), forKey: url)
        }
    }
    
    func getFromCache(with url: NSString) -> UIImage? {
        guard let data = cache.object(forKey: url) as? Data else { return UIImage(systemName: "gamepad") }
        return UIImage(data: data)
    }
}

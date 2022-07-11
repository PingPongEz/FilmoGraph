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
    
    func saveToCache(with url: NSString, and data: Data) {
        
        guard let uiimage = UIImage(data: data) else { return }
        cache.setObject(uiimage, forKey: url)
        
    }
    
    func getFromCache(with url: NSString) -> UIImage? {
        cache.object(forKey: url)
    }
    
    func cacheImage(with data: Data, _ response: URLResponse) {
        guard let url = response.url else { return }
        
        
        
        let request = URLRequest(url: url)
        let response = CachedURLResponse(response: response, data: data)
        
        URLCache.shared.storeCachedResponse(response, for: request)
    }
    
    func getCachedImage(from url: URL) -> UIImage? {
        
        let request = URLRequest(url: url)
        
        if let cachedResponce = URLCache.shared.cachedResponse(for: request) {
            return UIImage(data: cachedResponce.data)
        }
        
        return nil
    }
}

//
//  CacheImage.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 16/06/2022.
//

import Foundation
import UIKit

struct Cache {
    static func cacheImage(with data: Data, _ response: URLResponse) {
        guard let url = response.url else { return }
        
        let request = URLRequest(url: url)
        let response = CachedURLResponse(response: response, data: data)
        
        URLCache.shared.storeCachedResponse(response, for: request)
    }
    
    static func getCachedImage(from url: URL) -> UIImage? {
        
        let request = URLRequest(url: url)
        
        if let cachedResponce = URLCache.shared.cachedResponse(for: request) {
            return UIImage(data: cachedResponce.data)
        }
        
        return nil
    }
}

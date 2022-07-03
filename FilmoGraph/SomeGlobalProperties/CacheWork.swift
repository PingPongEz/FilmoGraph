//
//  CacheWork.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 17/06/2022.
//

import Foundation
import UIKit

class Cached {
    
    private init() {}
    static var shared = Cached()
    
    var loadedImages = NSCache<NSString, UIImage>()
}

class URLResquests {
    private init(){}
    static var shared = URLResquests()
    
    var runningRequests = [UUID?: URLSessionDataTask]()
    
    func deleteOneRequest(request: UUID?) {
        if runningRequests[request] != nil {
            runningRequests[request]?.cancel()
            runningRequests.removeValue(forKey: request)
        }
    }
    
    func cancelRequests(requests: [UUID?]) {
        requests.forEach { request in
            if runningRequests[request] != nil {
                runningRequests[request]?.cancel()
                runningRequests.removeValue(forKey: request)
            }
        }
    }
}

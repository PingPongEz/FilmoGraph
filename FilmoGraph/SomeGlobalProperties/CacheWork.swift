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
        runningRequests[request]?.cancel()
        runningRequests.removeValue(forKey: request)
    }
    
    func cancelRequests(requests: [UUID?]) {
        requests.forEach { request in
            runningRequests[request]?.cancel()
            runningRequests.removeValue(forKey: request)
            print("\(runningRequests.keys) in CLOUD")
        }
    }
}

//
//  CacheWork.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 17/06/2022.
//

import Foundation
import UIKit
import Alamofire

final class Cached {
    
    private init() {}
    static let shared = Cached()
    
    var loadedImages = NSCache<NSString, UIImage>()
}

final class URLResquests {
    
    private init(){}
    static let shared = URLResquests()
    private let semaphore = DispatchSemaphore(value: 1)
    
    var runningRequests = [UUID?: DataRequest]()
    
    func deleteOneRequest(request: UUID?) {
        semaphore.wait()
        if runningRequests[request] != nil {
            runningRequests[request]?.cancel()
            runningRequests.removeValue(forKey: request)
        }
        semaphore.signal()
    }
    
    func cancelRequests(requests: [UUID?]) {
        semaphore.wait()
        requests.forEach { request in
            runningRequests[request]?.cancel()
            runningRequests.removeValue(forKey: request)
        }
        semaphore.signal()
    }
    
    func addTasksToArray(uuid: UUID?, task: DataRequest) {
        semaphore.wait()
        runningRequests[uuid] = task
        semaphore.signal()
    }
}

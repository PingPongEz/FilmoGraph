//
//  CacheWork.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 17/06/2022.
//

import Foundation
import UIKit

final class Cached {
    
    private init() {}
    static let shared = Cached()
    
    var loadedImages = NSCache<NSString, UIImage>()
}

final class URLResquests {
    
    private init(){}
    static let shared = URLResquests()
    private let semaphore = DispatchSemaphore(value: 1)
    
    var runningRequests = [UUID?: URLSessionDataTask]()
    
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
            print(runningRequests.count)
            runningRequests[request]?.cancel()
            runningRequests.removeValue(forKey: request)
            print(runningRequests.count)
        }
        semaphore.signal()
    }
    
    func addTasksToArray(uuid: UUID?, task: URLSessionDataTask) {
        semaphore.wait()
        runningRequests[uuid] = task
        semaphore.signal()
    }
}

//
//  CacheWork.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 17/06/2022.
//

import Foundation
import UIKit
import Alamofire


final class URLResquests {
    
    private init(){}
    static let shared = URLResquests()
    private let semaphore = DispatchSemaphore(value: 1)
    private let queue = DispatchQueue(label: "Requests queue", qos: .default, attributes: .concurrent, target: .global())
    
    var runningRequests = [UUID?: DataRequest]()
    
    func deleteOneRequest(request: UUID?) {
        queue.async { [unowned self] in
            semaphore.wait()
            if runningRequests[request] != nil {
                runningRequests[request]?.cancel()
                runningRequests.removeValue(forKey: request)
            }
            semaphore.signal()
        }
    }
    
    func cancelRequests(requests: [UUID?]) {
        queue.async { [unowned self] in
            semaphore.wait()
            requests.forEach { request in
                runningRequests[request]?.cancel()
                runningRequests.removeValue(forKey: request)
            }
            semaphore.signal()
        }
    }
    
    func addTasksToArray(uuid: UUID?, task: DataRequest) {
        queue.async { [unowned self] in
            semaphore.wait()
            runningRequests[uuid] = task
            semaphore.signal()
        }
    }
}

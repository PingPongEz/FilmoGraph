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
    
    var runningRequests = [UUID: URLSessionDataTask]()
}

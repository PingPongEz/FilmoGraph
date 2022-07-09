//
//  Mutex.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 30/06/2022.
//

import Foundation

final class Mutex {
    
    private init(){}
    static var shared = Mutex()
    
    var available = false
    
    var mutex = pthread_mutex_t()
    var condition = pthread_cond_t()
}

final class LockMutex: Thread {
    
    var method: () -> Void
    
    init(completion: @escaping() -> Void) {
        pthread_cond_init(&Mutex.shared.condition, nil)
        pthread_mutex_init(&Mutex.shared.mutex, nil)
        self.method = completion
    }
    
    public override func main() {
        doSomethingMethod(completion: method)
    }
    
    func doSomethingMethod(completion: () -> Void)  {
        pthread_mutex_lock(&Mutex.shared.mutex)
        
        while (!Mutex.shared.available) {
            pthread_cond_wait(&Mutex.shared.condition, &Mutex.shared.mutex)
        }
        
        Mutex.shared.available = false
        defer { pthread_mutex_unlock(&Mutex.shared.mutex) }
        completion()
    }
}

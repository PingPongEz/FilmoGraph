//
//  Mutex.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 30/06/2022.
//

import Foundation

class Mutex {
    
    private init(){}
    static var shared = Mutex()
    
    var mutex = pthread_mutex_t()
    var condition = pthread_cond_t()
}


public class Condition: Thread {
    
    var available = true
    var method: () -> Void
    
    
    init(completion: @escaping() -> Void) {
        pthread_cond_init(&Mutex.shared.condition, nil)
        pthread_mutex_init(&Mutex.shared.mutex, nil)
        self.method = completion
    }
    
    public override func main() {
        doSomethingMethod(completion: method)
    }
    
    func turnItOn() {
        available = true
        pthread_cond_signal(&Mutex.shared.condition)
    }
    
    func doSomethingMethod<R>(completion: () throws -> R) rethrows -> R {
        pthread_mutex_lock(&Mutex.shared.mutex)
        while (!available) {
            pthread_cond_wait(&Mutex.shared.condition, &Mutex.shared.mutex)
        }
        available = false
        defer { pthread_mutex_unlock(&Mutex.shared.mutex) }
        return try completion()
    }
}

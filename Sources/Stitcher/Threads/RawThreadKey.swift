//
//  RawThreadKey.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 12/3/24.
//

import Foundation

class RawThreadKey<Value> {
    
    private var pthreadKey: pthread_key_t
    
    init() {
        pthreadKey = pthread_key_t()
        pthread_key_create(&pthreadKey) { destructor in
            guard let rawPointer = destructor as UnsafeMutableRawPointer? else { return }
            rawPointer.deallocate()
        }
    }
    
    deinit {
        pthread_key_delete(pthreadKey)
    }
    
    func read() -> Value? {
        guard let rawPtr = pthread_getspecific(pthreadKey) else {
            return nil
        }
        
        let intPtr = rawPtr.bindMemory(to: Value.self, capacity: 1)
        return intPtr.pointee
    }
    
    func write(_ value: Value) throws {
        let intPtr: UnsafeMutablePointer<Value> = .allocate(capacity: 1)
        intPtr.pointee = value
        
        let rawPtr = UnsafeRawPointer(intPtr)
        let resultStatus = pthread_setspecific(pthreadKey, rawPtr)
        
        guard let error = RawThreadKeyError.writeValueError(converting: resultStatus) else {
            return
        }
        
        throw error
    }
}

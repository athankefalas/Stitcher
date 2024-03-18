//
//  PipelineSubject.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 12/3/24.
//

import Foundation
import OpenCombine

#if canImport(Combine)
import Combine
#endif

class PipelineSubject<Output>: Pipeline {
    
    private let provider: AnyObject
    private let _send: (Output) -> Void
    
    let erasedProvider: Any
    
    init() {
        
#if canImport(Combine)
        if #available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *) {
            let subject = Combine.PassthroughSubject<Output, Never>()
            self.provider = subject
            self.erasedProvider = subject.eraseToAnyPublisher()
            self._send = { subject.send($0) }
        } else {
            // Fallback on earlier versions
            let subject = OpenCombine.PassthroughSubject<Output, Never>()
            self.provider = subject
            self.erasedProvider = subject.eraseToAnyPublisher()
            self._send = { 
                subject.send($0)
            }
        }
        
#else
        let subject = OpenCombine.PassthroughSubject<Output, Never>()
        self.provider = subject
        self.erasedProvider = subject.eraseToAnyPublisher()
        self._send = { subject.send($0) }
#endif
        
    }
    
    deinit {
        print("")
    }
    
    func send(_ value: Output) {
        _send(value)
    }
}

extension PipelineSubject where Output == Void {
    
    func send() {
        self.send(())
    }
}

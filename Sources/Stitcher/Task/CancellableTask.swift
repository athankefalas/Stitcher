//
//  CancellableTask.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 15/3/24.
//

import Foundation

/// A task that can be cancelled.
///
/// - Note: When swift concurrency is available `Task` and `TaskGroup` automatically conform to this protocol.
public protocol CancellableTask {
    
    func cancel()
}

@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
extension Task: CancellableTask {}

@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
extension TaskGroup: CancellableTask {
    
    public func cancel() {
        self.cancelAll()
    }
}

//
//  AsyncTask.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 12/3/24.
//

import Foundation

struct AsyncTask {
    
    enum Priority {
        case low
        case medium
        case high
        
        @available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
        var taskPriority: TaskPriority {
            switch self {
            case .low:
                return .low
            case .medium:
                return .medium
            case .high:
                return .high
            }
        }
    }
    
    @ThreadLocal
    private static var currentPriority: Priority = .high
    
    private static let lowPriorityQueue = DispatchQueue(
        label: "com.stitcher.AsyncTask.low-priority-queue",
        qos: .background
    )
    
    private static let mediumPriorityQueue = DispatchQueue(
        label: "com.stitcher.AsyncTask.medium-priority-queue",
        qos: .default
    )
    
    private static let highPriorityQueue = DispatchQueue(
        label: "com.stitcher.AsyncTask.high-priority-queue",
        qos: .userInitiated
    )
    
    private static func queue(for priority: Priority) -> DispatchQueue {
        switch priority {
        case .low:
            return lowPriorityQueue
        case .medium:
            return mediumPriorityQueue
        case .high:
            return highPriorityQueue
        }
    }
    
    private let provider: Any
    private let cancel: () -> Void
    
    @discardableResult
    init<TaskResult>(
        priority: Priority? = nil,
        operation: @Sendable @escaping () -> TaskResult,
        completion: @Sendable @escaping (TaskResult) -> Void = {_ in }
    ) {
        
        if #available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *) {
            let task = Task(priority: priority?.taskPriority) {
                let result = operation()
                
                guard !Task.isCancelled else {
                    return
                }
                
                completion(result)
            }
            
            self.provider = task
            self.cancel = {
                task.cancel()
            }
            
        } else {
            let priority = priority ?? Self.currentPriority
            let queue = Self.queue(for: priority)
            let canceller = Atomic(initialValue: false)
            
            self.provider = (queue, canceller)
            self.cancel = {
                canceller.wrappedValue = true
            }
            
            queue.async {
                let result = Self.$currentPriority.withValue(priority) {
                    operation()
                }
                
                guard !canceller.wrappedValue else {
                    return
                }
                
                completion(result)
            }
        }
    }
}

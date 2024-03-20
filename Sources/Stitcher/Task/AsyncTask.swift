//
//  AsyncTask.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 12/3/24.
//

import Foundation

@usableFromInline
final class AsyncTask: CancellableTask {
    
    static var _prefersSwiftConcurrency = true
    
    @usableFromInline
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
    
    private class QueueSet {
        
        private static var defaultQueueCount: Int {
            let processInfo = ProcessInfo()
            return processInfo.processorCount - 1
        }
        
        private var index: Int
        private var queues: [DispatchQueue]
        private var semaphore = DispatchSemaphore(value: 1)
        
        var queue: DispatchQueue {
            semaphore.wait()
            
            defer {
                semaphore.signal()
            }
            
            var nextIndex = index + 1
            
            if !queues.indices.contains(nextIndex) {
                nextIndex = 0
            }
            
            index = nextIndex
            return queues[nextIndex]
        }
        
        init(priority: DispatchQoS, count: Int? = nil) {
            let count = max(count ?? Self.defaultQueueCount, 1)
            self.index = -1
            self.queues = (0..<count).map { queueId in
                let label = "com.stitcher.AsyncTask.\(priority)-priority-queue.\(queueId)"
                return DispatchQueue(
                    label: label,
                    qos: priority
                )
            }
        }
    }
    
    @ThreadLocal
    private static var currentTask: AsyncTask? = nil
    
    @ThreadLocal
    private static var currentPriority: Priority = .high
    
    private static let lowPriorityQueues = QueueSet(priority: .background)
    private static let mediumPriorityQueues = QueueSet(priority: .default)
    private static let highPriorityQueues = QueueSet(priority: .userInitiated)
    
    private static func queue(for priority: Priority) -> DispatchQueue {
        switch priority {
        case .low:
            return lowPriorityQueues.queue
        case .medium:
            return mediumPriorityQueues.queue
        case .high:
            return highPriorityQueues.queue
        }
    }
    
    private let provider: Any
    private var isCancelled = false
    private let _cancel: () -> Void
    
    @usableFromInline
    static var isCancelled: Bool {
        if #available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *),
           Self._prefersSwiftConcurrency {
            return Task.isCancelled
        } else {
            return Self.currentTask?.isCancelled ?? false
        }
    }
    
    @usableFromInline
    @discardableResult
    init<TaskResult>(
        priority: Priority? = nil,
        operation: @Sendable @escaping () -> TaskResult,
        completion: @Sendable @escaping (TaskResult) -> Void = {_ in }
    ) {
        
        if #available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *),
           Self._prefersSwiftConcurrency {
            
            let task = Task(priority: priority?.taskPriority) {
                let result = operation()
                
                guard !Task.isCancelled else {
                    return
                }
                
                completion(result)
            }
            
            self.provider = task
            self._cancel = {
                task.cancel()
            }
            
        } else {
            let priority = priority ?? Self.currentPriority
            let queue = Self.queue(for: priority)
            let canceller = Atomic(initialValue: false)
            
            self.provider = (queue, canceller)
            self._cancel = {
                canceller.wrappedValue = true
            }
            
            queue.async {
                guard !canceller.wrappedValue else {
                    return
                }
                
                let result = Self.$currentTask.withValue(self) {
                    Self.$currentPriority.withValue(priority) {
                        operation()
                    }
                }
                
                guard !canceller.wrappedValue else {
                    return
                }
                
                completion(result)
            }
        }
    }
    
    @usableFromInline
    final func cancel() {
        isCancelled = true
        _cancel()
    }
}

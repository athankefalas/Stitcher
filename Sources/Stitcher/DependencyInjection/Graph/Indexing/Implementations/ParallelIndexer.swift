//
//  ParallelIndexer.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 15/3/24.
//

import Foundation
import OrderedCollections

public struct ParallelIndexer: Indexing {
    
    static var parallelTaskCount: Int {
        let coreCount = Double(ProcessInfo().processorCount)
        let maximumSystemLoadFactor = 0.75
        return Int(floor(coreCount * maximumSystemLoadFactor))
    }
    
    public init() {}
    
    public func index(
        dependencies: DependenciesRegistrar,
        coordinator: IndexingCoordinator,
        completion: @escaping (DependencyRegistrarIndex) -> Void
    ) -> any CancellableTask {
        
        let parallelTaskCount = Self.parallelTaskCount
        
        if parallelTaskCount < 2 {
            return taskIndexing(
                dependencies: dependencies,
                coordinator: coordinator,
                completion: completion
            )
        }
        
        let semaphore = DispatchSemaphore(value: 1)
        let indexingTask = IndexingTask()
        let dependencies = Array(dependencies)
        let taskCounterReference = Reference(wrappedValue: 0)
        let indexReference = Reference(wrappedValue: coordinator.emptyIndex())
        
        let handleSubtaskCompletion: (Int, DependencyRegistrarIndex) -> Void = { taskIndex, indexedRegistrar in
            semaphore.wait()
            
            defer {
                semaphore.signal()
            }
            
            let taskCounterValue = taskCounterReference.wrappedValue + 1
            taskCounterReference.wrappedValue = taskCounterValue
            indexReference.wrappedValue.merge(indexedRegistrar) { lhs, rhs in
                lhs.union(rhs)
            }
            
            guard taskCounterValue >= parallelTaskCount else {
                return
            }
            
            completion(indexReference.wrappedValue)
        }
        
        for taskIndex in 0..<parallelTaskCount {
            let slice = dependencies.slice(
                at: taskIndex,
                outOf: parallelTaskCount
            )
            
            let coordinator = coordinator.withEmptyIndex(
                by: { DependencyRegistrarIndex(minimumCapacity: slice.count * 3) }
            )
            
            let task = taskIndexing(
                dependencies: slice,
                coordinator: coordinator
            ) { completedDependencyIndex in
                handleSubtaskCompletion(
                    taskIndex,
                    completedDependencyIndex
                )
            }
            
            indexingTask.append(task)
        }
        
        return indexingTask
    }
}

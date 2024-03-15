//
//  PlainIndexing.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 15/3/24.
//

import Foundation
import OrderedCollections

/// A type that can be used to naively index dependencies.
struct PlainIndexing: Indexing {
    
    private static var subtaskCount: Int {
        let coreCount = Double(ProcessInfo().processorCount)
        return Int(round(coreCount * 0.5))
    }
    
    func index(
        dependencies: DependenciesRegistrar,
        reducer: IndexingReducer,
        completion: @escaping () -> Void
    ) -> any CancellableTask {
        
        let count = max(1, Self.subtaskCount)
        let indexingTask = IndexingTask()
        
        if count < 2 {
            let task = taskIndexing(
                dependencies: dependencies,
                reducer: reducer,
                completion: completion
            )
            
            indexingTask.append(task)
            return indexingTask
        }
        
        let completedTaskCount = Atomic(initialValue: 0)
        let subtaskCompletion: () -> Void = {
            completedTaskCount.wrappedValue += 1
            
            guard completedTaskCount.wrappedValue >= count else {
                return
            }
            
            completion()
        }
        
        let dependenciesArray = Array(dependencies)
        
        for slice in 0..<count {
            let task = taskIndexing(
                dependencies: dependenciesArray.slice(
                    at: slice,
                    outOf: count
                ),
                reducer: reducer,
                completion: subtaskCompletion
            )
            
            indexingTask.append(task)
        }
        
        return indexingTask
    }
    
    private func taskIndexing<S: Sequence>(
        dependencies: S,
        reducer: IndexingReducer,
        completion: @escaping () -> Void
    ) -> AsyncTask
    where S.Element == RawDependencyRegistration {
        
        AsyncTask(priority: .high) {
            for registration in dependencies {
                
                guard !AsyncTask.isCancelled else {
                    return
                }
                
                for key in registration.locator.indexingKeys() {
                    reducer.append(dependency: registration, toKey: key)
                }
                
                reducer.didIndex(dependency: registration)
            }
        } completion: {
            completion()
        }
    }
}


extension Array {
    
    func slice(
        at sliceIndex: Int,
        outOf total: Int
    ) -> ArraySlice<Element> {
        
        guard !self.isEmpty, sliceIndex < total else {
            return []
        }
        
        let sliceSize = Int(floor(Double(count) / Double(total)))
        let start = sliceIndex * sliceSize
        var end = start + sliceSize
        
        if sliceIndex == total - 1 {
            end = endIndex
        }
        
        return self[start..<end]
    }
}

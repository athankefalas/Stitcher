//
//  DependencyCycleDetector.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 15/2/24.
//

import Foundation
import Combine
import OrderedCollections

class DependencyCycleDetector {
    
    @TaskLocal
    fileprivate static var instantiationBacktrace: OrderedSet<DependencyLocator> = []
    
    fileprivate static func preventCycle(for locator: DependencyLocator) throws {
        guard !instantiationBacktrace.contains(locator) else {
            let backtrace = DependencyCycleInstantationBacktrace(
                instantiationBacktrace,
                triggeredBy: locator
            )
            
            throw InjectionError.cyclicDependencyReference(backtrace)
        }
    }
    
    fileprivate static func traceInstantiation<Result>(
        _ locator: DependencyLocator,
        instantiation: () throws -> Result
    ) throws -> Result {
        try $instantiationBacktrace.withValue(instantiationBacktrace.inserting(locator)) {
            try instantiation()
        }
    }
}

fileprivate extension OrderedSet {
    
    func inserting(_ element: Element) -> Self {
        var copy = self
        copy.append(element)
        
        return copy
    }
}

func withCycleDetection<Result>(
    _ locator: DependencyLocator,
    perform action: () throws -> Result
) throws -> Result {
    
    try DependencyCycleDetector.preventCycle(for: locator)
    
    return try DependencyCycleDetector.traceInstantiation(locator) {
        return try action()
    }
}

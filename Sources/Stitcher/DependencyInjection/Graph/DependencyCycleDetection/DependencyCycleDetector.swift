//
//  DependencyCycleDetector.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 15/2/24.
//

import Foundation
import Combine

class DependencyCycleDetector {
    
    @TaskLocal
    fileprivate static var instantiationBacktrace: Set<DependencyLocator> = []
    
    fileprivate static func preventCycle(for locator: DependencyLocator) throws {
        guard !instantiationBacktrace.contains(locator) else {
            throw InjectionError.cyclicDependencyReference(locator.dependencyContext())
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

fileprivate extension Set {
    
    func inserting(_ element: Element) -> Set<Element> {
        var copy = self
        copy.insert(element)
        
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

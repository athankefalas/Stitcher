//
//  DependencyCycleDetector.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 15/2/24.
//

import Foundation
import OrderedCollections

@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
fileprivate class DependencyCycleDetector {
    
    @TaskLocal
    fileprivate static var instantiationBacktrace: OrderedSet<DependencyLocator> = []
    
    fileprivate static func preventCycle(
        instantiating locator: DependencyLocator
    ) throws {
        
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

fileprivate class FallbackDependencyCycleDetector {
    
    @ThreadLocal
    fileprivate static var instantiationBacktrace: OrderedSet<DependencyLocator> = []
    
    fileprivate static func preventCycle(
        instantiating locator: DependencyLocator
    ) throws {
        
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
    
    if #available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *) {
        try DependencyCycleDetector.preventCycle(instantiating: locator)
        
        return try DependencyCycleDetector.traceInstantiation(locator) {
            return try action()
        }
    } else {
        // Fallback on earlier versions
        try FallbackDependencyCycleDetector.preventCycle(instantiating: locator)
        
        return try FallbackDependencyCycleDetector.traceInstantiation(locator) {
            return try action()
        }
    }
}

func withFallbackCycleDetection<Result>(
    _ locator: DependencyLocator,
    perform action: () throws -> Result
) throws -> Result {
    
    try FallbackDependencyCycleDetector.preventCycle(instantiating: locator)
    
    return try FallbackDependencyCycleDetector.traceInstantiation(locator) {
        return try action()
    }
}

//
//  DependencyCycleInstantationBacktrace.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 27/2/24.
//

import Foundation

/// A backtrace collected during instantiation of a dependency that had a cyclic relationship with another dependency.
public struct DependencyCycleInstantationBacktrace: CustomStringConvertible {
    
    /// The depth of the cycle.
    public let depth: Int
    
    /// An ordered sequence of the types that resulted in a cycle.
    public let cycle: [InjectionError.DependencyContext]
    
    public var description: String {
        return cycle
            .map(\.description)
            .joined(separator: " -> ")
    }
    
    init<Backtrace: Sequence>(
        _ backtrace: Backtrace,
        triggeredBy dependency: DependencyLocator
    ) where Backtrace.Element == DependencyLocator {
        var backtrace = Array(backtrace)
        backtrace.append(dependency)
        
        self.depth = backtrace.count
        self.cycle = backtrace.map({ $0.dependencyContext() })
    }
}

//
//  DependencyCycleInstantationBacktrace.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 27/2/24.
//

import Foundation

public struct DependencyCycleInstantationBacktrace: CustomStringConvertible {
    
    let depth: Int
    let cycle: [InjectionError.DependencyContext]
    
    public var description: String {
        let cycle = cycle
            .map(\.description)
            .joined(separator: " -> ")
        
        return "[Depth: \(depth), Cycle: \(cycle)]"
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

//
//  DependencyGraphPerformanceTests.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 28/2/24.
//

import XCTest
@testable import Stitcher

final class DependencyGraphPerformanceTests: XCTestCase {

    let range: ClosedRange<Int> = 1...100_000
    
    override func setUp() {
        StitcherConfiguration.isIndexingEnabled = true
        StitcherConfiguration.approximateDependencyCount = range.upperBound
    }

    func test_dependencyGraph_initialization() async throws {
        let container = DependencyContainer {
            RepeatDependency(for: self.range) { num in
                Dependency {
                    One()
                }
                .named("D\(num)")
            }
        }
        
        // Baseline: 100_000 @ 0,000137 s
        measure {
            DependencyGraph.activate(container)
        }
        
        DependencyGraph.deactivate(container)
    }
    
    func test_dependencyGraph_indexing() async {
        let container = DependencyContainer {
            RepeatDependency(for: self.range) { num in
                Dependency {
                    One()
                }
                .named("D\(num)")
            }
        }
        
        measure { // Baseline: 100_000 @ 0,369 s
            let expectation = XCTestExpectation()
            let indexedContainer = IndexedDependencyContainer(
                container: container,
                lazyInitializationHandler: {_ in }, completion: {}
            )
            
            Task {
                await self.backoff(until: !indexedContainer.indexing)
                expectation.fulfill()
            }
            
            wait(for: [expectation])
        }
    }
    
    func test_dependencyGraph_lookup() async throws {
        let container = DependencyContainer {
            RepeatDependency(for: self.range) { num in
                Dependency {
                    One()
                }
                .named("D\(num)")
            }
        }
        
        await DependencyGraph.activate(container)
        let num = Int.random(in: range)
        
        // Baseline: 100_000 @ 0,0000877 s
        measure {
            let _: One = try! DependencyGraph.inject(byName: "D\(num)")
        }
        
        DependencyGraph.deactivate(container)
    }
    
    func trackingTime<R>(
        for operation: String = "complete",
        _ block: () -> R
    ) -> R {
        let start = Date()
        let result = block()
        let end = Date()
        print("## Did \(operation) in \(end.timeIntervalSince(start)) seconds.")
        
        return result
    }
    
    func trackingTime<R>(
        for operation: String = "complete",
        _ block: () async -> R
    ) async -> R {
        let start = Date()
        let result = await block()
        let end = Date()
        print("## Did \(operation) in \(end.timeIntervalSince(start)) seconds.")
        
        return result
    }
    
    func delay(_ delayInterval: TimeInterval) async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.asyncAfter(deadline: .now() + delayInterval) {
                continuation.resume()
            }
        }
    }
    
    func backoff(
        for delayInterval: TimeInterval = 0.1,
        until condition: @escaping @autoclosure () -> Bool
    ) async {
        
        let increment = delayInterval
        var delayInterval = delayInterval
        
        while !condition() {
            await delay(delayInterval)
            delayInterval += increment
        }
    }
}

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

    func test_dependencyGraph_initialization() async throws {
        let container = DependencyContainer {
            RepeatDependencies(for: self.range) { num in
                Dependency {
                    One()
                }
                .named("D\(num)")
            }
        }
        
        // Baseline: 100_000 @ 0,0000917 s,
        measure {
            DependencyGraph.activate(container)
        }
        
        DependencyGraph.deactivate(container)
    }
    
    func test_dependencyGraph_lookup() async throws {
        let container = DependencyContainer {
            RepeatDependencies(for: self.range) { num in
                Dependency {
                    One()
                }
                .named("D\(num)")
            }
        }
        
        DependencyGraph.activate(container)
        let num = Int.random(in: range)
        
        await delay(0.35)
        
        // Baseline: 100_000 @ 0,000243 s
        measure {
            let dependency: One? = try? DependencyGraph.injectDependency(byName: "D\(num)")
            XCTAssertNotNil(dependency)
        }
        
        DependencyGraph.deactivate(container)
    }
    
    func trackingTime<R>(for operation: String, _ block: () -> R) -> R {
        let start = Date()
        let result = block()
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
}

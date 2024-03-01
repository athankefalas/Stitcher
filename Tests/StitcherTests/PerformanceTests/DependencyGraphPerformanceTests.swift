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

    func test_dependencyGraph_initialization() throws {
        let container = DependencyContainer {
            RepeatDependencies(for: self.range) { num in
                Dependency {
                    One()
                }
                .named("D\(num)")
            }
        }
        
//        measure { // Baseline: 100_000 @ 0.0139 s
//            DependencyGraph.activate(container)
//        }
        
        let start = Date()
        DependencyGraph.activate(container)
        let end = Date()
        print("## Activated container in \(end.timeIntervalSince(start)).")
        
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
        
        await delay(0.5)
        
        measure { // Baseline: 100_000 @ 0,0819 s
            let dependency: One? = try? DependencyGraph.injectDependency(byName: "D\(num)")
            XCTAssertNotNil(dependency)
        }
        
        DependencyGraph.deactivate(container)
    }
    
    func delay(_ delayInterval: TimeInterval) async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.asyncAfter(deadline: .now() + delayInterval) {
                continuation.resume()
            }
        }
    }
}

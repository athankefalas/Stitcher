//
//  DependencyGraphPerformanceTests.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 28/2/24.
//

import XCTest
@testable import Stitcher

final class DependencyGraphPerformanceTests: XCTestCase {

    static let range: ClosedRange<Int> = 1...1_000_000
    let container = DependencyContainer {
        RepeatDependencies(for: range) { num in
            Dependency {
                One()
            }
            .named("D\(num)")
        }
    }

    override func tearDownWithError() throws {
        DependencyGraph.deactivate(container)
    }

    func test_dependencyGraph_initialization() throws {
        measure { // Baseline: 1_000_000 @ 0.412
            DependencyGraph.activate(container)
        }
    }
    
    func test_dependencyGraph_lookup() throws {
        let num = Int.random(in: Self.range)
        DependencyGraph.activate(container)
        
        measure { // Baseline: 1_000_000 @ 0.107
            let dependency: One? = try? DependencyGraph.injectDependency(byName: "D\(num)")
            XCTAssertNotNil(dependency)
        }
    }
}

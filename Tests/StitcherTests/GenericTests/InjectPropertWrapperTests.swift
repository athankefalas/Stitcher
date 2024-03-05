//
//  InjectPropertWrapperTests.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 27/2/24.
//

import XCTest
import Stitcher

final class InjectPropertWrapperTests: XCTestCase {
    
    let container = DependencyContainer {
        Dependency {
            Alpha()
        }
        .named("Alpha")
        
        Dependency {
            Beta()
        }
        .conforms(to: LetterClassImplementing.self)
        
        Dependency {
            Gamma()
        }
        .conforms(to: LetterClassImplementing.self)
        
        Dependency {
            Delta()
        }
        .conforms(to: LetterClassImplementing.self)
        
        Dependency {
            Epsilon()
        }
        .associated(with: "Epsilon")
    }
    
    override func setUpWithError() throws {
        DependencyGraph.activate(container)
    }
    
    override func tearDownWithError() throws {
        DependencyGraph.deactivate(container)
    }
    
    func test_injected_byName() {
        @Injected(name: "Alpha")
        var dependency: Alpha?
        
        XCTAssertNotNil(dependency)
    }
    
    func test_injected_byNameFails() {
        @Injected(name: "Alpha ")
        var dependency: Alpha?
        
        XCTAssertNil(dependency)
    }
    
    func test_injected_byType() {
        @Injected
        var dependency: Beta
    }
    
    func test_injected_byOptionalType() {
        @Injected
        var dependency: Gamma?
        
        XCTAssertNotNil(dependency)
    }
    
    func test_injected_byAllMatchingTypes() {
        @Injected
        var dependency: [LetterClassImplementing]
        
        XCTAssert(dependency.count == 3)
    }
    
    @available(*, deprecated)
    func test_injected_byOptionalAllMatchingTypes() {
        @Injected
        var dependency: [LetterClassImplementing]?
        
        XCTAssert(dependency?.count == 3)
    }
    
    func test_injected_byValue() {
        @Injected(value: "Epsilon")
        var dependency: Epsilon?
        
        XCTAssertNotNil(dependency)
    }
    
    func test_injected_byValueFails() {
        @Injected(value: "Epsilon ")
        var dependency: Epsilon?
        
        XCTAssertNil(dependency)
    }
    
    func test_injected_loadIfNeeded() throws {
        let container = DependencyContainer {
            One()
        }
        
        @Injected
        var dependency: One?
        XCTAssertNil(dependency)
        
        let graphChangedExpectation = XCTestExpectation(description: "DependencyGraph Changed.")
        graphChangedExpectation.expectedFulfillmentCount = 1
        graphChangedExpectation.assertForOverFulfill = true
        
        let graphSubscription = DependencyGraph.graphChangedPublisher
            .sink {
                graphChangedExpectation.fulfill()
            }
        
        DependencyGraph.activate(container)
        
        defer {
            graphSubscription.cancel()
            DependencyGraph.deactivate(container)
        }
        
        wait(for: [graphChangedExpectation], timeout: 0.5)
        
        try _dependency.loadIfNeeded()
        XCTAssertNotNil(dependency)
    }
    
    func test_injected_reload() throws {
        @Injected
        var dependency: Beta
        let instanceId = ObjectIdentifier(dependency)
        
        try _dependency.reload()
        let updatedInstanceId = ObjectIdentifier(dependency)
        XCTAssertNotNil(instanceId != updatedInstanceId)
    }
    
    func test_injected_autoreload() throws {
        let container = DependencyContainer {
            One()
        }
        
        @Injected
        var dependency: One?
        _dependency.autoreload()
        XCTAssertNil(dependency)
        
        let graphChangedExpectation = XCTestExpectation(description: "DependencyGraph Changed.")
        graphChangedExpectation.expectedFulfillmentCount = 1
        graphChangedExpectation.assertForOverFulfill = true
        
        let graphSubscription = DependencyGraph.graphChangedPublisher
            .sink {
                graphChangedExpectation.fulfill()
            }
        
        DependencyGraph.activate(container)
        
        defer {
            graphSubscription.cancel()
            DependencyGraph.deactivate(container)
        }
        
        wait(for: [graphChangedExpectation], timeout: 0.5)
        XCTAssertNotNil(dependency)
    }
}

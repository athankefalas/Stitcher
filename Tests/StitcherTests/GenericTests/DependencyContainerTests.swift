//
//  DependencyContainerTests.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 26/2/24.
//

import XCTest
import Combine
@testable import Stitcher

final class DependencyContainerTests: XCTestCase {
    
    // Utility Types
    
    struct BetaRegistration: DependencyRepresenting {
        
        var dependencyProvider: DependencyFactory.Provider<Beta> {
            DependencyFactory.Provider {
                Beta()
            }
        }
    }
    
    static var zetaInitializations = 0
    
    class Zeta: Letter {
        override var value: Int { 6 }
        
        override init() {
            DependencyContainerTests.zetaInitializations += 1
        }
        
        deinit {
            DependencyContainerTests.zetaInitializations -= 1
        }
    }
    
    @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
    @Observable
    class StateHolder {
        var isOn: Bool
        
        init(isOn: Bool) {
            self.isOn = isOn
        }
    }
    
    class StateHolderObject: ObservableObject {
        @Published
        var isOn: Bool
        
        init(isOn: Bool) {
            self.isOn = isOn
        }
    }
    
    // Positive
    
    func test_dependencyContainer_registarBuilder() throws {
        let container = DependencyContainer {
            
            Dependency {
                Alpha()
            }
            
            BetaRegistration()
            
            DependencyGroup {
                Gamma()
            }
            
            Zeta()
        }
        
        DependencyGraph.activate(container)
        
        defer {
            DependencyGraph.deactivate(container)
        }
        
        let alpha: Alpha? = try DependencyGraph.inject()
        let beta: Beta? = try DependencyGraph.inject()
        let gamma: Gamma? = try DependencyGraph.inject()
        XCTAssertNotNil(alpha)
        XCTAssertNotNil(beta)
        XCTAssertNotNil(gamma)
        XCTAssert(Self.zetaInitializations == 0)
        
        let zeta: Zeta? = try DependencyGraph.inject()
        XCTAssertNotNil(zeta)
        XCTAssert(Self.zetaInitializations == 1)
    }

    func test_dependencyContainer_initialization() {
        let container = DependencyContainer {
            Dependency {
                Alpha()
            }
            .named("Alpha")
            
            Dependency {
                Alpha()
            }
            .named("Alpha")
            
            Dependency {
                Beta()
            }
            .named("Beta")
        }
        
        let alphaRegistrations = container.dependecyRegistrations(matching: .init(byName: "Alpha"))
        let betaRegistrations = container.dependecyRegistrations(matching: .init(byName: "Beta"))
        XCTAssert(alphaRegistrations.count == 1)
        XCTAssert(betaRegistrations.count == 1)
    }
    
    @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
    func test_dependencyContainer_observationInvalidation() throws {
        let state = StateHolder(isOn: true)
        let container = DependencyContainer {
            
            if state.isOn {
                Dependency {
                    Alpha()
                }
            }
            
            DependencyGroup {
                Beta()
            }
            .enabled(!state.isOn)
        }
        
        DependencyGraph.activate(container)
        
        let graphChangedExpectation = XCTestExpectation(description: "DependencyGraph Changed.")
        graphChangedExpectation.expectedFulfillmentCount = 1
        graphChangedExpectation.assertForOverFulfill = true
        
        let graphSubscription = DependencyGraph.graphChangedPublisher
            .sink {
                graphChangedExpectation.fulfill()
            }
        
        defer {
            graphSubscription.cancel()
            DependencyGraph.deactivate(container)
        }
        
        var alpha: Alpha? = try DependencyGraph.inject()
        var beta: Beta? = try DependencyGraph.inject()
        var alphaRegistrations = container.dependecyRegistrations(matching: .init(byType: Alpha.self))
        var betaRegistrations = container.dependecyRegistrations(matching: .init(byType: Beta.self))

        XCTAssertNotNil(alpha)
        XCTAssertNil(beta)
        XCTAssert(alphaRegistrations.count == 1)
        XCTAssert(betaRegistrations.count == 0)
        
        state.isOn.toggle()
        
        wait(for: [graphChangedExpectation], timeout: 0.5)
        
        alpha = try DependencyGraph.inject()
        beta = try DependencyGraph.inject()
        alphaRegistrations = container.dependecyRegistrations(matching: .init(byType: Alpha.self))
        betaRegistrations = container.dependecyRegistrations(matching: .init(byType: Beta.self))

        XCTAssertNil(alpha)
        XCTAssertNotNil(beta)
        XCTAssert(alphaRegistrations.count == 0)
        XCTAssert(betaRegistrations.count == 1)
    }
    
    func test_dependencyContainer_publisherInvalidation() throws {
        let state = StateHolderObject(isOn: true)
        let container = DependencyContainer {
            
            if state.isOn {
                Dependency {
                    Alpha()
                }
            }
            
            DependencyGroup {
                Beta()
            }
            .enabled(!state.isOn)
            
        }.invalidated(
            tracking: state
        )
        
        DependencyGraph.activate(container)
        
        let graphChangedExpectation = XCTestExpectation(description: "DependencyGraph Changed.")
        graphChangedExpectation.expectedFulfillmentCount = 1
        graphChangedExpectation.assertForOverFulfill = true
        
        let graphSubscription = DependencyGraph.graphChangedPublisher
            .sink {
                graphChangedExpectation.fulfill()
            }
        
        defer {
            graphSubscription.cancel()
            DependencyGraph.deactivate(container)
        }
        
        var alpha: Alpha? = try DependencyGraph.inject()
        var beta: Beta? = try DependencyGraph.inject()
        var alphaRegistrations = container.dependecyRegistrations(matching: .init(byType: Alpha.self))
        var betaRegistrations = container.dependecyRegistrations(matching: .init(byType: Beta.self))

        XCTAssertNotNil(alpha)
        XCTAssertNil(beta)
        XCTAssert(alphaRegistrations.count == 1)
        XCTAssert(betaRegistrations.count == 0)
        
        state.isOn.toggle()
        
        wait(for: [graphChangedExpectation], timeout: 0.5)
        
        alpha = try DependencyGraph.inject()
        beta = try DependencyGraph.inject()
        alphaRegistrations = container.dependecyRegistrations(matching: .init(byType: Alpha.self))
        betaRegistrations = container.dependecyRegistrations(matching: .init(byType: Beta.self))

        XCTAssertNil(alpha)
        XCTAssertNotNil(beta)
        XCTAssert(alphaRegistrations.count == 0)
        XCTAssert(betaRegistrations.count == 1)
    }
    
    func test_dependencyContainer_mergesDependencies() throws {
        let one = DependencyContainer {
            Dependency {
                Alpha()
            }
        }
        
        let other = DependencyContainer {
            Dependency {
                Beta()
            }
        }
        
        let container = DependencyContainer(merging: one, other)
        
        DependencyGraph.activate(container)
        
        defer {
            DependencyGraph.deactivate(container)
        }
        
        let alpha: Alpha? = try DependencyGraph.inject()
        let beta: Beta? = try DependencyGraph.inject()
        XCTAssertNotNil(alpha)
        XCTAssertNotNil(beta)
    }
    
    func test_dependencyContainer_mergesDependenciesAndInvalidations() throws {
        let state = StateHolderObject(isOn: true)
        let one = DependencyContainer {
            if state.isOn {
                Dependency {
                    Alpha()
                }
            }
        }.invalidated(
            tracking: state
        )
        
        let other = DependencyContainer {
            if !state.isOn {
                Dependency {
                    Beta()
                }
            }
        }.invalidated(
            tracking: state
        )
        
        let container = DependencyContainer(merging: one, other)
        DependencyGraph.activate(container)
        
        let graphChangedExpectation = XCTestExpectation(description: "DependencyGraph Changed.")
        graphChangedExpectation.expectedFulfillmentCount = 1
        graphChangedExpectation.assertForOverFulfill = true
        
        let graphSubscription = DependencyGraph.graphChangedPublisher
            .sink {
                graphChangedExpectation.fulfill()
            }
        
        defer {
            graphSubscription.cancel()
            DependencyGraph.deactivate(container)
        }
        
        var alpha: Alpha? = try DependencyGraph.inject()
        var beta: Beta? = try DependencyGraph.inject()
        XCTAssertNotNil(alpha)
        XCTAssertNil(beta)
        
        state.isOn.toggle()
        wait(for: [graphChangedExpectation], timeout: 0.5)
        
        alpha = try DependencyGraph.inject()
        beta = try DependencyGraph.inject()
        XCTAssertNil(alpha)
        XCTAssertNotNil(beta)
    }
}

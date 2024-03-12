//
//  DependencyScopeTests.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 26/2/24.
//

import XCTest
@testable import Stitcher

final class DependencyScopeAndEagernessTests: XCTestCase {

    static let invalidationSubject = PassthroughSubject<Void, Never>()
    static var eagerSharedDependencyInitCount = 0
    static var eagerSingletonDependencyInitCount = 0
    
    class EagerSharedDependency {
        init() {
            DependencyScopeAndEagernessTests.eagerSharedDependencyInitCount += 1
        }
        
        deinit {
            DependencyScopeAndEagernessTests.eagerSharedDependencyInitCount -= 1
        }
    }
    
    class EagerSingletonDependency {
        init() {
            DependencyScopeAndEagernessTests.eagerSingletonDependencyInitCount += 1
        }
        
        deinit {
            DependencyScopeAndEagernessTests.eagerSingletonDependencyInitCount -= 1
        }
    }
    
    let container = DependencyContainer {
        Dependency {
            Alpha()
        }
        .scope(.instance)
        
        Dependency {
            Beta()
        }
        .scope(.shared)
        
        Dependency {
            Gamma()
        }
        .scope(.singleton)
        
        Dependency {
            Delta()
        }
        .scope(.managed(by: invalidationSubject))
        
        Dependency {
            One()
        }
        .scope(.instance)
        
        Dependency {
            Two()
        }
        .scope(.shared)
        
        Dependency {
            Three()
        }
        .scope(.singleton)
        
        Dependency {
            Four()
        }
        .scope(.managed(by: invalidationSubject))
        
        Dependency {
            EagerSharedDependency()
        }
        .eagerness(.eager)
        
        Dependency {
            EagerSingletonDependency()
        }
        .scope(.singleton)
        .eagerness(.eager)
    }

    override func setUpWithError() throws {
        DependencyGraph.activate(container)
    }

    override func tearDownWithError() throws {
        DependencyGraph.deactivate(container)
    }
    
    // Detection
    
    func test_scopeDetection() {
        let referenceTypeDependency = Dependency {
            Alpha()
        }
        
        let valueTypeDependency = Dependency {
            One()
        }
        
        XCTAssert(referenceTypeDependency.scope == .shared)
        XCTAssert(valueTypeDependency.scope == .instance)
        
        let _: Two = try! DependencyGraph.inject()
    }
    
    // Reference Types

    func test_instanceScope_withReferenceTypes() throws {
        let one: Alpha = try DependencyGraph.inject()
        let other: Alpha = try DependencyGraph.inject()
        XCTAssert(one !== other)
    }
    
    func test_sharedScope_withReferenceTypes() throws {
        let one: Beta = try DependencyGraph.inject()
        let other: Beta = try DependencyGraph.inject()
        XCTAssert(one === other)
    }
    
    func test_sharedScopeWeakly_withReferenceTypes() throws {
        let objectId: () throws -> ObjectIdentifier = {
            var dependency: Beta = try DependencyGraph.inject()
            let result = ObjectIdentifier(dependency)
            dependency = Beta()
            
            return result
        }
        
        let oneId = try objectId()
        let otherId = try objectId()
        XCTAssert(oneId != otherId)
    }
    
    func test_singletonScope_withReferenceTypes() throws {
        let one: Gamma = try DependencyGraph.inject()
        let other: Gamma = try DependencyGraph.inject()
        XCTAssert(one === other)
    }
    
    func test_managedScope_withReferenceTypes() throws {
        let one: Delta = try DependencyGraph.inject()
        let other: Delta = try DependencyGraph.inject()
        XCTAssert(one === other)
    }
    
    func test_managedScopeInvalidates_withReferenceTypes() throws {
        let one: Delta = try DependencyGraph.inject()
        Self.invalidationSubject.send()
        
        let other: Delta = try DependencyGraph.inject()
        XCTAssert(one !== other)
    }
    
    // Value Types

    func test_instanceScope_withValueTypes() throws {
        let one: One = try DependencyGraph.inject()
        let other: One = try DependencyGraph.inject()
        XCTAssert(one.id != other.id)
    }
    
    func test_sharedScope_withValueTypes() throws {
        let one: Two = try DependencyGraph.inject()
        let other: Two = try DependencyGraph.inject()
        XCTAssert(one.id != other.id)
    }
    
    func test_singletonScope_withValueTypes() throws {
        let one: Three = try DependencyGraph.inject()
        let other: Three = try DependencyGraph.inject()
        XCTAssert(one.id == other.id)
    }
    
    func test_managedScope_withValueTypes() throws {
        let one: Four = try DependencyGraph.inject()
        let other: Four = try DependencyGraph.inject()
        XCTAssert(one.id == other.id)
    }
    
    func test_managedScopeInvalidates_withValueTypes() throws {
        let one: Four = try DependencyGraph.inject()
        Self.invalidationSubject.send()
        
        let other: Four = try DependencyGraph.inject()
        XCTAssert(one.id != other.id)
    }
    
    // Eagerness
    
    func test_eagerDependencyInstantiates() async throws {
        await delay(0.01)
        
        XCTAssert(Self.eagerSharedDependencyInitCount == 0)
        XCTAssert(Self.eagerSingletonDependencyInitCount == 1)
    }
    
    func delay(_ delayInterval: TimeInterval) async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.asyncAfter(deadline: .now() + delayInterval) {
                continuation.resume()
            }
        }
    }
}

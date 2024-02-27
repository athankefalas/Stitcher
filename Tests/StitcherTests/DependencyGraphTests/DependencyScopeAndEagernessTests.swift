//
//  DependencyScopeTests.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 26/2/24.
//

import XCTest
import Combine
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
        .scope(.tracking(invalidationSubject))
        
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
        .scope(.tracking(invalidationSubject))
        
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
        
        let _: Two = try! DependencyGraph.injectDependency()
    }
    
    // Reference Types

    func test_instanceScope_withReferenceTypes() throws {
        let one: Alpha = try DependencyGraph.injectDependency()
        let other: Alpha = try DependencyGraph.injectDependency()
        XCTAssert(one !== other)
    }
    
    func test_sharedScope_withReferenceTypes() throws {
        let one: Beta = try DependencyGraph.injectDependency()
        let other: Beta = try DependencyGraph.injectDependency()
        XCTAssert(one === other)
    }
    
    func test_sharedScopeWeakly_withReferenceTypes() throws {
        let objectId: () throws -> ObjectIdentifier = {
            var dependency: Beta = try DependencyGraph.injectDependency()
            let result = ObjectIdentifier(dependency)
            dependency = Beta()
            
            return result
        }
        
        let oneId = try objectId()
        let otherId = try objectId()
        XCTAssert(oneId != otherId)
    }
    
    func test_singletonScope_withReferenceTypes() throws {
        let one: Gamma = try DependencyGraph.injectDependency()
        let other: Gamma = try DependencyGraph.injectDependency()
        XCTAssert(one === other)
    }
    
    func test_managedScope_withReferenceTypes() throws {
        let one: Delta = try DependencyGraph.injectDependency()
        let other: Delta = try DependencyGraph.injectDependency()
        XCTAssert(one === other)
    }
    
    func test_managedScopeInvalidates_withReferenceTypes() throws {
        let one: Delta = try DependencyGraph.injectDependency()
        Self.invalidationSubject.send()
        
        let other: Delta = try DependencyGraph.injectDependency()
        XCTAssert(one !== other)
    }
    
    // Eagerness
    
    func test_eagerDependencyInstantiates() throws {
        XCTAssert(Self.eagerSharedDependencyInitCount == 0)
        XCTAssert(Self.eagerSingletonDependencyInitCount == 1)
    }
}

//
//  TypeInjectionTests.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 26/2/24.
//

import XCTest
@testable import Stitcher

final class TypeInjectionTests: XCTestCase {
    
    let container = DependencyContainer {
        Dependency {
            Alpha()
        }
        .inherits(from: Letter.self)
        .conforms(to: LetterClassImplementing.self)
        .conforms(to: TypePrinting.self)
        
        Dependency {
            Beta()
        }
        .inherits(from: Letter.self)
        .conforms(to: LetterClassImplementing.self)
        
        Dependency {
            Gamma()
        }
        .inherits(from: Letter.self)
        .conforms(to: LetterClassImplementing.self)
        
        Dependency {
            Delta()
        }
        .inherits(from: Letter.self)
        .conforms(to: LetterClassImplementing.self)
    }

    override func setUpWithError() throws {
        DependencyGraph.activate(container)
    }

    override func tearDownWithError() throws {
        DependencyGraph.deactivate(container)
    }
    
    // Positive

    func test_injectionByType_findsAlphaDependency() throws {
        let dependency: Alpha = try DependencyGraph.injectDependency()
        XCTAssert(dependency.value == Alpha().value)
    }
    
    func test_injectionByType_findsBetaDependency() throws {
        let dependency: Beta = try DependencyGraph.injectDependency()
        XCTAssert(dependency.value == Beta().value)
    }
    
    func test_injectionByType_findsGammaDependency() throws {
        let dependency: Gamma = try DependencyGraph.injectDependency()
        XCTAssert(dependency.value == Gamma().value)
    }
    
    func test_injectionByType_findsDeltaDependency() throws {
        let dependency: Delta = try DependencyGraph.injectDependency()
        XCTAssert(dependency.value == Delta().value)
    }

    func test_injectionByType_findsDependencyByProtocolConformance() throws {
        let dependency: TypePrinting = try DependencyGraph.injectDependency()
        XCTAssert(dependency.printType() == Alpha().printType())
    }
    
    func test_injectionByType_findsNilForOptionalDependency() throws {
        let dependency: Epsilon? = try DependencyGraph.injectDependency()
        XCTAssertNil(dependency)
    }
    
    func test_injectionByType_findsDependenciesByProtocolConformance() throws {
        let dependencies: [LetterClassImplementing] = try DependencyGraph.injectDependency()
        XCTAssert(dependencies.count == 4)
    }
    
    func test_injectionByType_findsDependenciesByInheritedSuperclass() throws {
        let dependencies: [Letter] = try DependencyGraph.injectDependency()
        XCTAssert(dependencies.count == 4)
    }
    
    func test_injectionByType_findsOptionalDependenciesByProtocolConformance() throws {
        let dependencies: [LetterClassImplementing]? = try DependencyGraph.injectDependency(
            byType: [LetterClassImplementing]?.self
        )
        
        XCTAssert(dependencies?.count == 4)
    }
    
    func test_injectionByType_findsOptionalDependenciesByInheritedSuperclass() throws {
        let dependencies: [Letter]? = try DependencyGraph.injectDependency(
            byType: [Letter]?.self
        )
        
        XCTAssert(dependencies?.count == 4)
    }
}

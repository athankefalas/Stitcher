//
//  TypeInjectionTests.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 26/2/24.
//

import XCTest
import Stitcher

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
        let dependency: Alpha = try DependencyGraph.inject()
        XCTAssert(dependency.value == Alpha().value)
    }
    
    func test_injectionByType_findsBetaDependency() throws {
        let dependency: Beta = try DependencyGraph.inject()
        XCTAssert(dependency.value == Beta().value)
    }
    
    func test_injectionByType_findsGammaDependency() throws {
        let dependency: Gamma = try DependencyGraph.inject()
        XCTAssert(dependency.value == Gamma().value)
    }
    
    func test_injectionByType_findsDeltaDependency() throws {
        let dependency: Delta = try DependencyGraph.inject()
        XCTAssert(dependency.value == Delta().value)
    }

    func test_injectionByType_findsDependencyByProtocolConformance() throws {
        let dependency: TypePrinting = try DependencyGraph.inject()
        XCTAssert(dependency.printType() == Alpha().printType())
    }
    
    func test_injectionByType_findsNilForOptionalDependency() throws {
        let dependency: Epsilon? = try DependencyGraph.inject()
        XCTAssertNil(dependency)
    }
    
    func test_injectionByType_findsDependenciesByProtocolConformance() throws {
        let dependencies: [LetterClassImplementing] = try DependencyGraph.inject()
        XCTAssert(dependencies.count == 4)
    }
    
    func test_injectionByType_findsDependenciesByInheritedSuperclass() throws {
        let dependencies: [Letter] = try DependencyGraph.inject()
        XCTAssert(dependencies.count == 4)
    }
    
    @available(*, deprecated)
    func test_injectionByType_findsOptionalDependenciesByProtocolConformance() throws {
        let dependencies: [LetterClassImplementing]? = try DependencyGraph.inject(
            byType: [LetterClassImplementing]?.self
        )
        
        XCTAssert(dependencies?.count == 4)
    }
    
    @available(*, deprecated)
    func test_injectionByType_findsOptionalDependenciesByInheritedSuperclass() throws {
        let dependencies: [Letter]? = try DependencyGraph.inject(
            byType: [Letter]?.self
        )
        
        XCTAssert(dependencies?.count == 4)
    }
}

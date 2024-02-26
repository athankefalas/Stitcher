//
//  ValueInjectionTests.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 26/2/24.
//

import XCTest
import Stitcher

final class ValueInjectionTests: XCTestCase {
    
    enum Dependencies: Hashable {
        case alpha
        case beta
        case gamma
    }
    
    let container = DependencyContainer {
        Dependency {
            Alpha()
        }
        .associated(with: Dependencies.alpha)
        
        Dependency {
            Beta()
        }
        .associated(with: Dependencies.beta)
        
        Dependency {
            Gamma()
        }
        .associated(with: Dependencies.gamma)
    }

    override func setUpWithError() throws {
        DependencyGraph.activate(container)
    }

    override func tearDownWithError() throws {
        DependencyGraph.deactivate(container)
    }

    // Positivie
    
    func test_injectionByValue_findsAlphaDependency() throws {
        let dependency: Alpha = try DependencyGraph.injectDependency(byValue: Dependencies.alpha)
        XCTAssert(dependency.value == Alpha().value)
    }
    
    func test_injectionByValue_findsBetaDependency() throws {
        let dependency: Beta = try DependencyGraph.injectDependency(byValue: Dependencies.beta)
        XCTAssert(dependency.value == Beta().value)
    }
    
    func test_injectionByValue_findsGammaDependency() throws {
        let dependency: Gamma = try DependencyGraph.injectDependency(byValue: Dependencies.gamma)
        XCTAssert(dependency.value == Gamma().value)
    }
}

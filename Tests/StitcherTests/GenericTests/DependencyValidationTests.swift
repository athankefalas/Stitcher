//
//  DependencyValidationTests.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 27/2/24.
//

import XCTest
import Stitcher

final class DependencyValidationTests: XCTestCase {
    
    struct InvalidDependenciesError: Error {}

    let container = DependencyContainer {
        
        Dependency {
            Alpha()
        }
        .named("Alpha")
        
        Dependency {
            Beta()
        }
        
        Dependency { 
            Gamma()
        }
        .associated(with: "Gamma")
    }
    
    override func setUpWithError() throws {
        DependencyGraph.activate(container)
    }

    override func tearDownWithError() throws {
        DependencyGraph.deactivate(container)
    }

    func test_graphValidations() throws {
        DependencyGraph.validate { registrar in
            
            XCTAssert(registrar.count == 3)
            
            registrar.withMatches(where: { $0.isLocatedBy(name: "Alpha") }) { dependencies in
                XCTAssert(dependencies.count == 1)
            }
            
            registrar.withMatches(where: { $0.isLocatedBy(type: Beta.self) }) { dependencies in
                XCTAssert(dependencies.count == 1)
            }
            
            registrar.withMatches(where: { $0.isLocatedBy(value: "Gamma") }) { dependencies in
                XCTAssert(dependencies.count == 1)
            }
        }
    }
}

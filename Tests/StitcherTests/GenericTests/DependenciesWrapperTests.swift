//
//  DependenciesWrapperTests.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 27/2/24.
//

import XCTest
import Stitcher

final class DependenciesWrapperTests: XCTestCase {
    
    @Dependencies
    var container = .empty

    override func setUpWithError() throws {
        container = DependencyContainer {
            Alpha()
            
            One()
        }
    }

    override func tearDownWithError() throws {
        container = .empty
    }

    func test_dependenciesWrapper_activates() throws {
        XCTAssert(container != .empty)
        
        let dependency: Alpha? = try DependencyGraph.injectDependency()
        XCTAssertNotNil(dependency)
    }
    
    func test_dependenciesWrapper_deactivates() throws {
        XCTAssert(container != .empty)
        container = .empty
        
        let dependency: Alpha? = try DependencyGraph.injectDependency()
        XCTAssertNil(dependency)
    }
}

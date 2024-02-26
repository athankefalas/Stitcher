//
//  InjectionParameterTests.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 26/2/24.
//

import XCTest
import Stitcher

final class InjectionParameterTests: XCTestCase {

    let container = DependencyContainer {
        Dependency {
            Values<String>()
        }
        
        Dependency { v0 in
            Values<Int>(values: v0)
        }
        
        Dependency { v0, v1 in
            Values<Double>(values: v0, v1)
        }
    }
    
    override func setUpWithError() throws {
        DependencyGraph.activate(container)
    }

    override func tearDownWithError() throws {
        DependencyGraph.deactivate(container)
    }

    func test_injectionParameters_arityZero() throws {
        let values: Values<String> = try DependencyGraph.injectDependency()
        XCTAssert(values.values.count == 0)
        XCTAssert(values.description == "")
    }
    
    func test_injectionParameters_arityOne() throws {
        let values: Values<Int> = try DependencyGraph.injectDependency(parameters: 11)
        XCTAssert(values.values.count == 1)
        XCTAssert(values.description == "11")
    }

    func test_injectionParameters_arityTwo() throws {
        let values: Values<Double> = try DependencyGraph.injectDependency(parameters: 21.0, 22.0)
        XCTAssert(values.values.count == 2)
        XCTAssert(values.description == "21.0, 22.0")
    }
}

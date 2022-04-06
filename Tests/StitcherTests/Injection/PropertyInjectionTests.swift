//
//  PropertyInjectionTests.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 25/3/22.
//

import XCTest
import Stitcher

class PropertyInjectionTests: XCTestCase {

    private static var alphaValue = "A"
    private static var betaValue = Double(0.0)
    
    // MARK: Tests
    
    override func setUpWithError() throws {
        try DependencyGraph.activate {
            DependencyContainer("Tests") {
                Dependency(property: "Alpha") {
                    Self.alphaValue
                } set: { newValue in
                    Self.alphaValue = newValue
                }
                
                Dependency(property: "Beta") {
                    Self.betaValue
                } set: { newValue in
                    Self.betaValue = newValue
                }
            }
        }
    }
    
    // MARK: Happy
    
    func test_propertyInjection_alphaProperty() throws {
        let sut = DependencyGraph.active
        var property: PropertyImplementation<String> = try assertSucceeds {
            try sut.injectProperty(named: "Alpha")
        }
        
        var expectedResult = Self.alphaValue
        XCTAssertEqual(property.value, expectedResult)
        
        expectedResult = "Test"
        property.value = expectedResult
        XCTAssertEqual(Self.alphaValue, expectedResult)
    }
    
    func test_propertyInjection_betaProperty() throws {
        let sut = DependencyGraph.active
        var property: PropertyImplementation<Double> = try assertSucceeds {
            try sut.injectProperty(named: "Beta")
        }
        
        var expectedResult = Self.betaValue
        XCTAssertEqual(property.value, expectedResult)
        
        expectedResult = 0.5
        property.value = expectedResult
        XCTAssertEqual(Self.betaValue, expectedResult)
    }
    
}

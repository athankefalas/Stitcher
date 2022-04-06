//
//  SyntheticTypesTests.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 25/3/22.
//

import XCTest
import Stitcher

class SyntheticTypesTests: XCTestCase {
    
    private static var property: String = ""
    
    private static func function() -> String {
        return "function"
    }
    
    private static func otherFunction(parameter1: String, parameter2: Int) -> String {
        return "otherFunction:\(parameter1),\(parameter2)"
    }
    
    override func setUpWithError() throws {
        try DependencyGraph.activate {
            DependencyContainer("Tests") {
                Dependency(property: SyntheticTestingType.propertyName) {
                    Self.property
                } set: { newValue in
                    Self.property = newValue
                }
                
                Dependency(function: SyntheticTestingType.functionName, Self.function)
                
                Dependency(function: SyntheticTestingType.otherFunctionName, Self.otherFunction)
            }
        }
    }
    
    func test_syntheticType_property() throws {
        let sut = SyntheticTestingType()
        
        let expectedResult = "Test"
        sut.property = expectedResult
        XCTAssertEqual(sut.property, Self.property)
        XCTAssertEqual(Self.property, expectedResult)
    }
    
    func test_syntheticType_function() throws {
        let sut = SyntheticTestingType()
        
        let expectedResult = Self.function()
        XCTAssertEqual(sut.function(), expectedResult)
    }
    
    func test_syntheticType_otherFunction() throws {
        let sut = SyntheticTestingType()
        
        let p1 = "John Doe"
        let p2 = 33
        
        let expectedResult = Self.otherFunction(parameter1: p1, parameter2: p2)
        XCTAssertEqual(sut.otherFunction(parameter1: p1, parameter2: p2), expectedResult)
    }

}

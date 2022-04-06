//
//  DependencyLocatorTests.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 16/1/22.
//

import XCTest
import Stitcher

class DependencyLocatorTests: XCTestCase {

    func test_DependencyLocator_Name_URNIsValid() throws {
        let dependencyLocator = DependencyLocator.name("Name")
        let rawValue = dependencyLocator.rawValue
        let expectedRawValue = "urn:stitcher:dependency-locator:name?name=Name"
        
        XCTAssertEqual(rawValue, expectedRawValue, "")
    }
    
    func test_DependencyLocator_Name_IsCreatedByURN() throws {
        let urn = "urn:stitcher:dependency-locator:name?name=Foo"
        var dependencyLocator = DependencyLocator(rawValue: urn)
        
        dependencyLocator = try XCTUnwrap(dependencyLocator)
        
        XCTAssertEqual(dependencyLocator, .name("Foo"))
    }
    
    
    func test_DependencyLocator_Type_URNIsValid() throws {
        let dependencyLocator = DependencyLocator.type(String.self)
        let rawValue = dependencyLocator.rawValue
        let expectedRawValue = "urn:stitcher:dependency-locator:type?type=String"
        
        XCTAssertEqual(rawValue, expectedRawValue, "")
    }
    
    func test_DependencyLocator_Type_IsCreatedByURN() throws {
        let urn = "urn:stitcher:dependency-locator:type?type=String"
        var dependencyLocator = DependencyLocator(rawValue: urn)
        
        dependencyLocator = try XCTUnwrap(dependencyLocator)
        
        XCTAssertEqual(dependencyLocator, .type("String"))
    }
    
    func test_DependencyLocator_TypeAndSupertypes_URNIsValid() throws {
        let dependencyLocator = DependencyLocator.type(String.self, supertype: Array<Character>.self)
        let rawValue = dependencyLocator.rawValue
        let expectedRawValue = "urn:stitcher:dependency-locator:type?type=String&supertypes=Array<Character>"
        
        XCTAssertEqual(rawValue, expectedRawValue, "")
    }
    
    func test_DependencyLocator_TypeAndSupertypes_IsCreatedByURN() throws {
        let urn = "urn:stitcher:dependency-locator:type?type=String&supertypes=StringProtocol"
        var dependencyLocator = DependencyLocator(rawValue: urn)
        
        dependencyLocator = try XCTUnwrap(dependencyLocator)
        
        XCTAssertEqual(dependencyLocator, .type("String", supertypes: ["StringProtocol"]))
    }
    

    func test_DependencyLocator_Function_URNIsValid() throws {
        let dependencyLocator = DependencyLocator.function("temp", accepting: String.self, String.self, returning: Void.self)
        let rawValue = dependencyLocator.rawValue
        let expectedRawValue = "urn:stitcher:dependency-locator:func?name=temp&parameters=String,String&result=()"
        
        XCTAssertEqual(rawValue, expectedRawValue, "")
    }
    
    func test_DependencyLocator_Function_IsCreatedByURN() throws {
        let urn = "urn:stitcher:dependency-locator:func?name=temp&parameters=String,String&result=()"
        var dependencyLocator = DependencyLocator(rawValue: urn)
        
        dependencyLocator = try XCTUnwrap(dependencyLocator)
        
        XCTAssertEqual(dependencyLocator, .function("temp", accepting: String.self, String.self, returning: Void.self))
    }
    
    
    func test_DependencyLocator_Property_URNIsValid() throws {
        let dependencyLocator = DependencyLocator.property("Name", type: "String")
        let rawValue = dependencyLocator.rawValue
        let expectedRawValue = "urn:stitcher:dependency-locator:property?name=Name&type=String"
        
        XCTAssertEqual(rawValue, expectedRawValue, "")
    }
    
    func test_DependencyLocator_Property_IsCreatedByURN() throws {
        let urn = "urn:stitcher:dependency-locator:property?name=Foo&type=String"
        var dependencyLocator = DependencyLocator(rawValue: urn)
        
        dependencyLocator = try XCTUnwrap(dependencyLocator)
        
        XCTAssertEqual(dependencyLocator, .property("Foo", type: "String"))
    }
    
    
}

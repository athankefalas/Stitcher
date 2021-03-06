//
// MIT License
//
// Copyright (c) 2022 Athanasios Kefalas
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
//
//  DependencyLocatorTests.swift
//  
//
//  Created by Athanasios Kefalas on 16/1/22.
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

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
//  SyntheticTypesTests.swift
//  
//
//  Created by Athanasios Kefalas on 25/3/22.
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

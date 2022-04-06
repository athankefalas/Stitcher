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
//  PropertyInjectionTests.swift
//  
//
//  Created by Athanasios Kefalas on 25/3/22.
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

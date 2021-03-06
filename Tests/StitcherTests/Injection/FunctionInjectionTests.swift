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
//  FunctionInjectionTests.swift
//  
//
//  Created by Athanasios Kefalas on 22/3/22.
//

import XCTest
import Stitcher

class FunctionInjectionTests: XCTestCase {

    private static var alphaValue = "Alpha"
    private static var betaValue = "Beta"
    private static var gammaValue = "Gamma"
    private static var deltaValue = "Delta"
    private static var epsilonValue = Double(0.5)
    
    private static var invocations: [FunctionName] = []
    
    private enum FunctionName: String, Equatable {
        case alpha
        case beta
        case gamma
        case delta
        case epsilon
    }
    
    private static func alphaFunction() -> String {
        invocations.append(.alpha)
        return alphaValue
    }
    
    private static func betaFunction() -> Int {
        invocations.append(.beta)
        return betaValue.count
    }
    
    private static func gammaFunction(repeats count: Int) -> String {
        invocations.append(.gamma)
        return Array(repeating: gammaValue, count: count).joined(separator: ",")
    }
    
    private static func deltaFunction(suffix: String) -> String {
        invocations.append(.delta)
        return "\(deltaValue)\(suffix)"
    }
    
    private static func epsilonFunction() -> Double {
        invocations.append(.epsilon)
        return epsilonValue
    }
    
    // MARK: Tests
    
    override func setUpWithError() throws {
        Self.invocations.removeAll()
        
        try DependencyGraph.activate {
            DependencyContainer("Tests") {
                Dependency(function: "A", Self.alphaFunction)
                
                Dependency(function: "B", Self.betaFunction)
                
                Dependency(function: "G", Self.gammaFunction)
                
                Dependency(function: "D", Self.deltaFunction)
                
                Dependency {
                    Self.epsilonFunction
                }
            }
        }
    }
    
    // MARK: Happy
    
    func test_functionInjection_alphaFunction() throws {
        let sut = DependencyGraph.active
        let function: () -> String = try assertSucceeds {
            try sut.injectFunction(named: "A")
        }
        
        let expectedResult = Self.alphaValue
        
        XCTAssertEqual(function(), expectedResult)
        XCTAssertEqual(Self.invocations, [.alpha])
    }
    
    func test_functionInjection_betaFunction() throws {
        let sut = DependencyGraph.active
        let function: () -> Int = try assertSucceeds {
            try sut.injectFunction(named: "B")
        }
        
        let expectedResult = Self.betaValue.count
        
        XCTAssertEqual(function(), expectedResult)
        XCTAssertEqual(Self.invocations, [.beta])
    }
    
    func test_functionInjection_gammaFunction() throws {
        let sut = DependencyGraph.active
        let function: (Int) -> String = try assertSucceeds {
            try sut.injectFunction(named: "G")
        }
        
        let repeatCount = 2
        let expectedResult = Array(repeating: Self.gammaValue, count: repeatCount).joined(separator: ",")
        
        XCTAssertEqual(function(repeatCount), expectedResult)
        XCTAssertEqual(Self.invocations, [.gamma])
    }
    
    func test_functionInjection_deltaFunction() throws {
        let sut = DependencyGraph.active
        let function: (String) -> String = try assertSucceeds {
            try sut.injectFunction(named: "D")
        }
        
        let suffix = "__"
        let expectedResult = "\(Self.deltaValue)\(suffix)"
        
        XCTAssertEqual(function(suffix), expectedResult)
        XCTAssertEqual(Self.invocations, [.delta])
    }
    
    func test_functionInjection_byResultType() throws {
        let sut = DependencyGraph.active
        let function: () -> Double = try sut.inject()
        
        XCTAssertEqual(function(), Self.epsilonValue)
        XCTAssertEqual(Self.invocations, [.epsilon])
    }
    
    // MARK: Unhappy
    
    func test_functionInjection_byResultTypeFails() throws {
        let sut = DependencyGraph.active
        try assertFails {
            let _: () -> String = try sut.inject()
        }
    }
}

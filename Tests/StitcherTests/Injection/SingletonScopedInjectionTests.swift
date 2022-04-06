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
//  SingletonScopedInjectionTests.swift
//  
//
//  Created by Athanasios Kefalas on 22/3/22.
//

import XCTest
import Stitcher

class SingletonScopedInjectionTests: XCTestCase {
    
    private static let alpha = Alpha()
    
    override func setUpWithError() throws {
        try DependencyGraph.activate {
            DependencyContainer("Tests") {
                Dependency(Self.alpha)
            }
        }
    }
    
    // MARK: Happy
    
    func test_injection_ofSingleton() throws {
        let sut = DependencyGraph.active
        let reference: Alpha = try assertSucceeds {
            try sut.inject()
        }
        
        let otherReference: Alpha = try assertSucceeds {
            try sut.inject()
        }
        
        let sharedValue = "Test"
        reference.string = sharedValue
        
        XCTAssertEqual(reference.string, otherReference.string)
    }
}

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
//  InjectionNotificationTests.swift
//  
//
//  Created by Athanasios Kefalas on 22/3/22.
//

import XCTest
import Stitcher

class InjectionNotificationTests: XCTestCase {

    private static let alpha = Alpha()
    
    override func setUpWithError() throws {
        try DependencyGraph.activate {
            DependencyContainer("Tests") {
                Dependency("A", Alpha.init)
                Dependency(Self.alpha)
            }
        }
    }
    
    // MARK: Happy
    
    func test_injection_notificationsInvoked() throws {
        let sut = DependencyGraph.active
        let instance: Alpha = try assertSucceeds {
            try sut.inject(named: "A")
        }
        
        XCTAssertEqual(instance.actions, [
            .postInstantiationNotification,
            .preInjetionNotification])
    }
    
    func test_injection_notificationsInvokedInSingleton() throws {
        let sut = DependencyGraph.active
        let instance: Alpha = try assertSucceeds {
            try sut.inject()
        }
        
        let _: Alpha = try assertSucceeds {
            try sut.inject()
        }
        
        XCTAssertEqual(instance.actions, [
            .postInstantiationNotification,
            .preInjetionNotification,
            .postInstantiationNotification,
            .preInjetionNotification])
    }

}

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
//  AsyncFunctionInvocation.swift
//  
//
//  Created by Athanasios Kefalas on 6/3/22.
//

import Foundation

/// A type that locates an async function from the active dependency graph and provides a way to invoke it.
@available(iOS 13.0.0, macOS 10.15.0, tvOS 13.0.0, watchOS 6.0.0, *)
open class AsyncFunctionInvocation<P, R>: UnsafeSyntheticMember {
    
    private let functionInvocation: () async -> R
    
    public init(_ name: String) where P == Void {
        warnUnsafeSynthticUsage(function: name)
        
        let function: () async -> R = try! DependencyGraph.active.injectFunction(named: name)
        
        self.functionInvocation = {
            await function()
        }
    }
    
    public init(_ name: String, _ p1: P) {
        warnUnsafeSynthticUsage(function: name)
        
        let function: (P) async -> R = try! DependencyGraph.active.injectFunction(named: name)
        
        self.functionInvocation = {
            await function(p1)
        }
    }
    
    public init<P1, P2>(_ name: String, _ p1: P1, _ p2: P2) where P == (P1, P2) {
        warnUnsafeSynthticUsage(function: name)
        
        let function: (P1, P2) async -> R = try! DependencyGraph.active.injectFunction(named: name)
        
        self.functionInvocation = {
            await function(p1, p2)
        }
    }
    
    public init<P1, P2, P3>(_ name: String, _ p1: P1, _ p2: P2, _ p3: P3) where P == (P1, P2, P3) {
        warnUnsafeSynthticUsage(function: name)
        
        let function: (P1, P2, P3) async -> R = try! DependencyGraph.active.injectFunction(named: name)
        
        self.functionInvocation = {
            await function(p1, p2, p3)
        }
    }
    
    public init<P1, P2, P3, P4>(_ name: String, _ p1: P1, _ p2: P2, _ p3: P3, _ p4: P4) where P == (P1, P2, P3, P4) {
        warnUnsafeSynthticUsage(function: name)
        
        let function: (P1, P2, P3, P4) async -> R = try! DependencyGraph.active.injectFunction(named: name)
        
        self.functionInvocation = {
            await function(p1, p2, p3, p4)
        }
    }
    
    public init<P1, P2, P3, P4, P5>(_ name: String, _ p1: P1, _ p2: P2, _ p3: P3, _ p4: P4, _ p5: P5) where P == (P1, P2, P3, P4, P5) {
        warnUnsafeSynthticUsage(function: name)
        
        let function: (P1, P2, P3, P4, P5) async -> R = try! DependencyGraph.active.injectFunction(named: name)
        
        self.functionInvocation = {
            await function(p1, p2, p3, p4, p5)
        }
    }
    
    public init<P1, P2, P3, P4, P5, P6>(_ name: String, _ p1: P1, _ p2: P2, _ p3: P3, _ p4: P4, _ p5: P5, _ p6: P6) where P == (P1, P2, P3, P4, P5, P6) {
        warnUnsafeSynthticUsage(function: name)
        
        let function: (P1, P2, P3, P4, P5, P6) async -> R = try! DependencyGraph.active.injectFunction(named: name)
        
        self.functionInvocation = {
            await function(p1, p2, p3, p4, p5, p6)
        }
    }
    
    public init<P1, P2, P3, P4, P5, P6, P7>(_ name: String, _ p1: P1, _ p2: P2, _ p3: P3, _ p4: P4, _ p5: P5, _ p6: P6, _ p7: P7) where P == (P1, P2, P3, P4, P5, P6, P7) {
        warnUnsafeSynthticUsage(function: name)
        
        let function: (P1, P2, P3, P4, P5, P6, P7) async -> R = try! DependencyGraph.active.injectFunction(named: name)
        
        self.functionInvocation = {
            await function(p1, p2, p3, p4, p5, p6, p7)
        }
    }
    
    open func invoke() async -> R {
        return await functionInvocation()
    }
}

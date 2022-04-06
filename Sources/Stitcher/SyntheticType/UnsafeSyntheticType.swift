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
//  UnsafeSyntheticType.swift
//  
//
//  Created by Athanasios Kefalas on 6/3/22.
//

import Foundation

/// Represents a type that is partly, or completely, synthesized with properties and functions from the active `DependencyGraph`.
/// - Warning: Synthetic types are an unsafe feature that could result in runtime errors, use them only in cases when the requirements of a type,
/// are undeniably and veryfiably, defined within the active dependency graph.
public protocol UnsafeSyntheticType {}

public extension UnsafeSyntheticType {
    
    func synthesizeInvocation<R>(function: String) -> R {
        return FunctionInvocation(function).invoke()
    }
    
    func synthesizeInvocation<R, P1>(function: String, _ p1: P1) -> R {
        return FunctionInvocation(function, p1).invoke()
    }
    
    func synthesizeInvocation<R, P1, P2>(function: String, _ p1: P1, _ p2: P2) -> R {
        return FunctionInvocation(function, p1, p2).invoke()
    }
    
    func synthesizeInvocation<R, P1, P2, P3>(function: String, _ p1: P1, _ p2: P2, _ p3: P3) -> R {
        return FunctionInvocation(function, p1, p2, p3).invoke()
    }
    
    func synthesizeInvocation<R, P1, P2, P3, P4>(function: String, _ p1: P1, _ p2: P2, _ p3: P3, _ p4: P4) -> R {
        return FunctionInvocation(function, p1, p2, p3, p4).invoke()
    }
    
    func synthesizeInvocation<R, P1, P2, P3, P4, P5>(function: String, _ p1: P1, _ p2: P2, _ p3: P3, _ p4: P4, _ p5: P5) -> R {
        return FunctionInvocation(function, p1, p2, p3, p4, p5).invoke()
    }
    
    func synthesizeInvocation<R, P1, P2, P3, P4, P5, P6>(function: String, _ p1: P1, _ p2: P2, _ p3: P3, _ p4: P4, _ p5: P5, _ p6: P6) -> R {
        return FunctionInvocation(function, p1, p2, p3, p4, p5, p6).invoke()
    }
    
    func synthesizeInvocation<R, P1, P2, P3, P4, P5, P6, P7>(function: String, _ p1: P1, _ p2: P2, _ p3: P3, _ p4: P4, _ p5: P5, _ p6: P6, _ p7: P7) -> R {
        return FunctionInvocation(function, p1, p2, p3, p4, p5, p6, p7).invoke()
    }
    
    func synthesize<T>(property: String) -> PropertyImplementation<T> {
        return Property(property).implementation()
    }
    
    // MARK: Raw Representable Overloads
    
    func synthesizeInvocation<F: RawRepresentable, R>(function: F) -> R where F.RawValue == String {
        return FunctionInvocation(function.rawValue).invoke()
    }
    
    func synthesizeInvocation<F: RawRepresentable, R, P1>(function: F, _ p1: P1) -> R where F.RawValue == String {
        return FunctionInvocation(function.rawValue, p1).invoke()
    }
    
    func synthesizeInvocation<F: RawRepresentable, R, P1, P2>(function: F, _ p1: P1, _ p2: P2) -> R where F.RawValue == String {
        return FunctionInvocation(function.rawValue, p1, p2).invoke()
    }
    
    func synthesizeInvocation<F: RawRepresentable, R, P1, P2, P3>(function: F, _ p1: P1, _ p2: P2, _ p3: P3) -> R where F.RawValue == String {
        return FunctionInvocation(function.rawValue, p1, p2, p3).invoke()
    }
    
    func synthesizeInvocation<F: RawRepresentable, R, P1, P2, P3, P4>(function: F, _ p1: P1, _ p2: P2, _ p3: P3, _ p4: P4) -> R where F.RawValue == String {
        return FunctionInvocation(function.rawValue, p1, p2, p3, p4).invoke()
    }
    
    func synthesizeInvocation<F: RawRepresentable, R, P1, P2, P3, P4, P5>(function: F, _ p1: P1, _ p2: P2, _ p3: P3, _ p4: P4, _ p5: P5) -> R where F.RawValue == String {
        return FunctionInvocation(function.rawValue, p1, p2, p3, p4, p5).invoke()
    }
    
    func synthesizeInvocation<F: RawRepresentable, R, P1, P2, P3, P4, P5, P6>(function: F, _ p1: P1, _ p2: P2, _ p3: P3, _ p4: P4, _ p5: P5, _ p6: P6) -> R where F.RawValue == String {
        return FunctionInvocation(function.rawValue, p1, p2, p3, p4, p5, p6).invoke()
    }
    
    func synthesizeInvocation<F: RawRepresentable, R, P1, P2, P3, P4, P5, P6, P7>(function: F, _ p1: P1, _ p2: P2, _ p3: P3, _ p4: P4, _ p5: P5, _ p6: P6, _ p7: P7) -> R where F.RawValue == String {
        return FunctionInvocation(function.rawValue, p1, p2, p3, p4, p5, p6, p7).invoke()
    }
    
    func synthesize<P: RawRepresentable, T>(property: P) -> PropertyImplementation<T> where P.RawValue == String {
        return Property(property.rawValue).implementation()
    }
}

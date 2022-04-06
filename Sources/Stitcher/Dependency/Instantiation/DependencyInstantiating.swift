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
//  DependencyInstantiating.swift
//  
//
//  Created by Athanasios Kefalas on 27/3/22.
//

import Foundation

/// A type that can be used to instantiate a dependency
public protocol DependencyInstantiating: Hashable {
    associatedtype Instance
    
    /// An array of the types required as parameters when instantiating the dependency stored as Strings
    var parameterTypes: [String] { get }
    /// The count of the parameters required when instantiating the dependency
    var parameterCount: UInt { get }
    
    /// Creates a new instance of the dependency by using the given parameters
    /// - Parameter parameters: An array of type erased parameters
    /// - Returns: An instance of the dependency
    func instantiate(parameters: [Any?]) throws -> Instance
}

public extension DependencyInstantiating {
    
    var parameterCount: UInt {
        UInt(parameterTypes.count)
    }
    
}

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
//  DependencyInstantiator.swift
//  
//
//  Created by Athanasios Kefalas on 27/2/22.
//

import Foundation

/// A type that can be used to instantiate a dependency of type `DependencyInstance`.
public struct DependencyInstantiator<DependencyInstance>: DependencyInstantiating {
    public typealias Instantiator = ([Any?]) throws -> DependencyInstance
    
    public let parameterCount: UInt
    public let parameterTypes: [String]
    
    private let instantiator: Instantiator
    
    public init(parameterTypes: [Any.Type], _ instantiator: @escaping Instantiator) {
        self.parameterTypes = parameterTypes.map({ "\($0)" })
        self.parameterCount = UInt(parameterTypes.count)
        self.instantiator = instantiator
    }
    
    public func instantiate(parameters: [Any?]) throws -> DependencyInstance {
        guard parameters.count == parameterCount else {
            throw InstantiationError.incorrectParameterCount
        }
        
        do {
            let instance = try instantiator(parameters)
            
            if let postInstantiationNotified = instance as? PostInstantiationNotified {
                postInstantiationNotified.didInstantiate()
            }
            
            return instance
        } catch {
            
            if let instantiationError = error as? InstantiationError {
                throw instantiationError
            }
            
            throw InstantiationError.instantiationFailed
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(parameterCount)
        hasher.combine(parameterTypes)
    }
    
    public static func == (lhs: DependencyInstantiator, rhs: DependencyInstantiator) -> Bool {
        return lhs.parameterCount == rhs.parameterCount
            && lhs.parameterTypes == rhs.parameterTypes
    }
}

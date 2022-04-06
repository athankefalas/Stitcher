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
//  PropertyImplementation.swift
//  
//
//  Created by Athanasios Kefalas on 12/3/22.
//

import Foundation

/// A type that encapsulates the implementation of a property's getter and setter.
public struct PropertyImplementation<T> {
    private let getter: () -> T
    private let setter: (T) -> Void
    
    /// The value of the encapsulated property
    public var value: T {
        get {
            getter()
        }
        
        set {
            setter(newValue)
        }
    }
    
    /// Creates a new property implementation with the given getter and setter functions
    /// - Parameters:
    ///   - getter: The property's getter function
    ///   - setter: The property's setter function
    public init(get getter: @escaping () -> T, set setter: @escaping (T) -> Void) {
        self.getter = getter
        self.setter = setter
    }
}

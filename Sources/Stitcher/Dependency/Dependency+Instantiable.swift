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
//  Dependency+Instantiable.swift
//  
//
//  Created by Athanasios Kefalas on 19/3/22.
//

import Foundation

public extension Dependency {
    
    init<T: Instantiable>(_ type: T.Type = T.self) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return T()
        }
        
        self.init(.type(type), dependencyInstantiator)
    }
    
    init<T: Instantiable>(_ dependencyName: String, _ type: T.Type = T.self) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return T()
        }
        
        self.init(.name(dependencyName), dependencyInstantiator)
    }
    
    init<T: Instantiable>(_ dependencyLocator: DependencyLocator, _ type: T.Type = T.self) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return T()
        }
        
        self.init(dependencyLocator, dependencyInstantiator)
    }
    
}

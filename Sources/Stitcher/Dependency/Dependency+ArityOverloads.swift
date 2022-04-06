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
//  Dependency+ArityOverloads.swift
//  
//
//  Created by Athanasios Kefalas on 20/3/22.
//

import Foundation

// MARK: Arity 0 Extensions

public extension Dependency {
    
    init<T>(_ dependencyName: String, _ instatiator: @escaping () -> T) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return instatiator()
        }
        
        self.init(.name(dependencyName), dependencyInstantiator)
    }
    
    init<T>(_ instatiator: @escaping () -> T) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return instatiator()
        }
        
        self.init(.type(T.self), dependencyInstantiator)
    }
    
    init<T>(_ instatiator: @autoclosure @escaping () -> T) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return instatiator()
        }
        
        self.init(.type(T.self), dependencyInstantiator)
    }
    
    init<T, S>(implementing supertype: S.Type, _ instatiator: @escaping () -> T) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return instatiator()
        }
        
        self.init(.type(T.self, supertype: supertype), dependencyInstantiator)
    }
    
    init<T>(_ dependencyLocator: DependencyLocator, _ instatiator: @escaping () -> T) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return instatiator()
        }
        
        switch dependencyLocator {
        case .function(let name, _, _):
            warn("Declaring a function dependency requires the use of the Dependency(_:, implementation:) initializer.")
            warn("The function '\(name)' will be treated as an instatiation function, instead of a dependency.")
        default:
            break
        }
        
        self.init(dependencyLocator, dependencyInstantiator)
    }
}

// MARK: Arity 1 Extensions

public extension Dependency {
    
    init<P1, T>(_ dependencyName: String, _ instatiator: @escaping (P1) -> T) {
        let dependencyInstantiator = DependencyInstantiator<T>(parameterTypes: [P1.self]) { params in
            let p1 = try params.parameterAt(0, as: P1.self)
            return instatiator(p1)
        }
        
        self.init(.name(dependencyName), dependencyInstantiator)
    }
    
    init<P1, T>(_ instatiator: @escaping (P1) -> T) {
        let dependencyInstantiator = DependencyInstantiator<T>(parameterTypes: [P1.self]) { params in
            let p1 = try params.parameterAt(0, as: P1.self)
            return instatiator(p1)
        }
        
        self.init(.type(T.self), dependencyInstantiator)
    }
    
    init<P1, T, S>(implementing supertype: S.Type, _ instatiator: @escaping (P1) -> T) {
        let dependencyInstantiator = DependencyInstantiator<T>(parameterTypes: [P1.self]) { params in
            let p1 = try params.parameterAt(0, as: P1.self)
            return instatiator(p1)
        }
        
        self.init(.type(T.self, supertype: supertype), dependencyInstantiator)
    }
    
    init<P1, T>(_ dependencyLocator: DependencyLocator, _ instatiator: @escaping (P1) -> T) {
        let dependencyInstantiator = DependencyInstantiator<T>(parameterTypes: [P1.self]) { params in
            let p1 = try params.parameterAt(0, as: P1.self)
            return instatiator(p1)
        }
        
        self.init(dependencyLocator, dependencyInstantiator)
    }
}

// MARK: Arity 2 Extensions

public extension Dependency {
    
    init<P1, P2, T>(_ dependencyName: String, _ instatiator: @escaping (P1, P2) -> T) {
        let dependencyInstantiator = DependencyInstantiator<T>(parameterTypes: [P1.self, P2.self]) { params in
            let p1 = try params.parameterAt(0, as: P1.self)
            let p2 = try params.parameterAt(1, as: P2.self)
            return instatiator(p1, p2)
        }
        
        self.init(.name(dependencyName), dependencyInstantiator)
    }
    
    init<P1, P2, T>(_ instatiator: @escaping (P1, P2) -> T) {
        let dependencyInstantiator = DependencyInstantiator<T>(parameterTypes: [P1.self, P2.self]) { params in
            let p1 = try params.parameterAt(0, as: P1.self)
            let p2 = try params.parameterAt(1, as: P2.self)
            return instatiator(p1, p2)
        }
        
        self.init(.type(T.self), dependencyInstantiator)
    }
    
    init<P1, P2, T, S>(implementing supertype: S.Type, _ instatiator: @escaping (P1, P2) -> T) {
        let dependencyInstantiator = DependencyInstantiator<T>(parameterTypes: [P1.self, P2.self]) { params in
            let p1 = try params.parameterAt(0, as: P1.self)
            let p2 = try params.parameterAt(1, as: P2.self)
            return instatiator(p1, p2)
        }
        
        self.init(.type(T.self, supertype: supertype), dependencyInstantiator)
    }
    
    init<P1, P2, T>(_ dependencyLocator: DependencyLocator, _ instatiator: @escaping (P1, P2) -> T) {
        let dependencyInstantiator = DependencyInstantiator<T>(parameterTypes: [P1.self, P2.self]) { params in
            let p1 = try params.parameterAt(0, as: P1.self)
            let p2 = try params.parameterAt(1, as: P2.self)
            return instatiator(p1, p2)
        }
        
        self.init(dependencyLocator, dependencyInstantiator)
    }
}

// MARK: Arity 3 Extensions

public extension Dependency {
    
    init<P1, P2, P3, T>(_ dependencyName: String, _ instatiator: @escaping (P1, P2, P3) -> T) {
        let dependencyInstantiator = DependencyInstantiator<T>(parameterTypes: [P1.self, P2.self, P3.self]) { params in
            let p1 = try params.parameterAt(0, as: P1.self)
            let p2 = try params.parameterAt(1, as: P2.self)
            let p3 = try params.parameterAt(2, as: P3.self)
            return instatiator(p1, p2, p3)
        }
        
        self.init(.name(dependencyName), dependencyInstantiator)
    }
    
    init<P1, P2, P3, T>(_ instatiator: @escaping (P1, P2, P3) -> T) {
        let dependencyInstantiator = DependencyInstantiator<T>(parameterTypes: [P1.self, P2.self, P3.self]) { params in
            let p1 = try params.parameterAt(0, as: P1.self)
            let p2 = try params.parameterAt(1, as: P2.self)
            let p3 = try params.parameterAt(2, as: P3.self)
            return instatiator(p1, p2, p3)
        }
        
        self.init(.type(T.self), dependencyInstantiator)
    }
    
    init<P1, P2, P3, T, S>(implementing supertype: S.Type, _ instatiator: @escaping (P1, P2, P3) -> T) {
        let dependencyInstantiator = DependencyInstantiator<T>(parameterTypes: [P1.self, P2.self, P3.self]) { params in
            let p1 = try params.parameterAt(0, as: P1.self)
            let p2 = try params.parameterAt(1, as: P2.self)
            let p3 = try params.parameterAt(2, as: P3.self)
            return instatiator(p1, p2, p3)
        }
        
        self.init(.type(T.self, supertype: supertype), dependencyInstantiator)
    }
    
    init<P1, P2, P3, T>(_ dependencyLocator: DependencyLocator, _ instatiator: @escaping (P1, P2, P3) -> T) {
        let dependencyInstantiator = DependencyInstantiator<T>(parameterTypes: [P1.self, P2.self, P3.self]) { params in
            let p1 = try params.parameterAt(0, as: P1.self)
            let p2 = try params.parameterAt(1, as: P2.self)
            let p3 = try params.parameterAt(2, as: P3.self)
            return instatiator(p1, p2, p3)
        }
        
        self.init(dependencyLocator, dependencyInstantiator)
    }
}

// MARK: Arity 4 Extensions

public extension Dependency {
    
    init<P1, P2, P3, P4, T>(_ dependencyName: String, _ instatiator: @escaping (P1, P2, P3, P4) -> T) {
        let dependencyInstantiator = DependencyInstantiator<T>(parameterTypes: [P1.self, P2.self, P3.self, P4.self]) { params in
            let p1 = try params.parameterAt(0, as: P1.self)
            let p2 = try params.parameterAt(1, as: P2.self)
            let p3 = try params.parameterAt(2, as: P3.self)
            let p4 = try params.parameterAt(3, as: P4.self)
            return instatiator(p1, p2, p3, p4)
        }
        
        self.init(.name(dependencyName), dependencyInstantiator)
    }
    
    init<P1, P2, P3, P4, T>(_ instatiator: @escaping (P1, P2, P3, P4) -> T) {
        let dependencyInstantiator = DependencyInstantiator<T>(parameterTypes: [P1.self, P2.self, P3.self, P4.self]) { params in
            let p1 = try params.parameterAt(0, as: P1.self)
            let p2 = try params.parameterAt(1, as: P2.self)
            let p3 = try params.parameterAt(2, as: P3.self)
            let p4 = try params.parameterAt(3, as: P4.self)
            return instatiator(p1, p2, p3, p4)
        }
        
        self.init(.type(T.self), dependencyInstantiator)
    }
    
    init<P1, P2, P3, P4, T, S>(implementing supertype: S.Type, _ instatiator: @escaping (P1, P2, P3, P4) -> T) {
        let dependencyInstantiator = DependencyInstantiator<T>(parameterTypes: [P1.self, P2.self, P3.self, P4.self]) { params in
            let p1 = try params.parameterAt(0, as: P1.self)
            let p2 = try params.parameterAt(1, as: P2.self)
            let p3 = try params.parameterAt(2, as: P3.self)
            let p4 = try params.parameterAt(3, as: P4.self)
            return instatiator(p1, p2, p3, p4)
        }
        
        self.init(.type(T.self, supertype: supertype), dependencyInstantiator)
    }
    
    init<P1, P2, P3, P4, T>(_ dependencyLocator: DependencyLocator, _ instatiator: @escaping (P1, P2, P3, P4) -> T) {
        let dependencyInstantiator = DependencyInstantiator<T>(parameterTypes: [P1.self, P2.self, P3.self, P4.self]) { params in
            let p1 = try params.parameterAt(0, as: P1.self)
            let p2 = try params.parameterAt(1, as: P2.self)
            let p3 = try params.parameterAt(2, as: P3.self)
            let p4 = try params.parameterAt(3, as: P4.self)
            return instatiator(p1, p2, p3, p4)
        }
        
        self.init(dependencyLocator, dependencyInstantiator)
    }
}

// MARK: Arity 5 Extensions

public extension Dependency {
    
    init<P1, P2, P3, P4, P5, T>(_ dependencyName: String, _ instatiator: @escaping (P1, P2, P3, P4, P5) -> T) {
        let dependencyInstantiator = DependencyInstantiator<T>(parameterTypes: [P1.self, P2.self, P3.self, P4.self, P5.self]) { params in
            let p1 = try params.parameterAt(0, as: P1.self)
            let p2 = try params.parameterAt(1, as: P2.self)
            let p3 = try params.parameterAt(2, as: P3.self)
            let p4 = try params.parameterAt(3, as: P4.self)
            let p5 = try params.parameterAt(4, as: P5.self)
            return instatiator(p1, p2, p3, p4, p5)
        }
        
        self.init(.name(dependencyName), dependencyInstantiator)
    }
    
    init<P1, P2, P3, P4, P5, T>(_ instatiator: @escaping (P1, P2, P3, P4, P5) -> T) {
        let dependencyInstantiator = DependencyInstantiator<T>(parameterTypes: [P1.self, P2.self, P3.self, P4.self, P5.self]) { params in
            let p1 = try params.parameterAt(0, as: P1.self)
            let p2 = try params.parameterAt(1, as: P2.self)
            let p3 = try params.parameterAt(2, as: P3.self)
            let p4 = try params.parameterAt(3, as: P4.self)
            let p5 = try params.parameterAt(4, as: P5.self)
            return instatiator(p1, p2, p3, p4, p5)
        }
        
        self.init(.type(T.self), dependencyInstantiator)
    }
    
    init<P1, P2, P3, P4, P5, T, S>(implementing supertype: S.Type, _ instatiator: @escaping (P1, P2, P3, P4, P5) -> T) {
        let dependencyInstantiator = DependencyInstantiator<T>(parameterTypes: [P1.self, P2.self, P3.self, P4.self, P5.self]) { params in
            let p1 = try params.parameterAt(0, as: P1.self)
            let p2 = try params.parameterAt(1, as: P2.self)
            let p3 = try params.parameterAt(2, as: P3.self)
            let p4 = try params.parameterAt(3, as: P4.self)
            let p5 = try params.parameterAt(4, as: P5.self)
            return instatiator(p1, p2, p3, p4, p5)
        }
        
        self.init(.type(T.self, supertype: supertype), dependencyInstantiator)
    }
    
    init<P1, P2, P3, P4, P5, T>(_ dependencyLocator: DependencyLocator, _ instatiator: @escaping (P1, P2, P3, P4, P5) -> T) {
        let dependencyInstantiator = DependencyInstantiator<T>(parameterTypes: [P1.self, P2.self, P3.self, P4.self, P5.self]) { params in
            let p1 = try params.parameterAt(0, as: P1.self)
            let p2 = try params.parameterAt(1, as: P2.self)
            let p3 = try params.parameterAt(2, as: P3.self)
            let p4 = try params.parameterAt(3, as: P4.self)
            let p5 = try params.parameterAt(4, as: P5.self)
            return instatiator(p1, p2, p3, p4, p5)
        }
        
        self.init(dependencyLocator, dependencyInstantiator)
    }
}

// MARK: Arity 6 Extensions

public extension Dependency {
    
    init<P1, P2, P3, P4, P5, P6, T>(_ dependencyName: String, _ instatiator: @escaping (P1, P2, P3, P4, P5, P6) -> T) {
        let dependencyInstantiator = DependencyInstantiator<T>(parameterTypes: [P1.self, P2.self, P3.self, P4.self, P5.self, P6.self]) { params in
            let p1 = try params.parameterAt(0, as: P1.self)
            let p2 = try params.parameterAt(1, as: P2.self)
            let p3 = try params.parameterAt(2, as: P3.self)
            let p4 = try params.parameterAt(3, as: P4.self)
            let p5 = try params.parameterAt(4, as: P5.self)
            let p6 = try params.parameterAt(5, as: P6.self)
            return instatiator(p1, p2, p3, p4, p5, p6)
        }
        
        self.init(.name(dependencyName), dependencyInstantiator)
    }
    
    init<P1, P2, P3, P4, P5, P6, T>(_ instatiator: @escaping (P1, P2, P3, P4, P5, P6) -> T) {
        let dependencyInstantiator = DependencyInstantiator<T>(parameterTypes: [P1.self, P2.self, P3.self, P4.self, P5.self, P6.self]) { params in
            let p1 = try params.parameterAt(0, as: P1.self)
            let p2 = try params.parameterAt(1, as: P2.self)
            let p3 = try params.parameterAt(2, as: P3.self)
            let p4 = try params.parameterAt(3, as: P4.self)
            let p5 = try params.parameterAt(4, as: P5.self)
            let p6 = try params.parameterAt(5, as: P6.self)
            return instatiator(p1, p2, p3, p4, p5, p6)
        }
        
        self.init(.type(T.self), dependencyInstantiator)
    }
    
    init<P1, P2, P3, P4, P5, P6, T, S>(implementing supertype: S.Type, _ instatiator: @escaping (P1, P2, P3, P4, P5, P6) -> T) {
        let dependencyInstantiator = DependencyInstantiator<T>(parameterTypes: [P1.self, P2.self, P3.self, P4.self, P5.self, P6.self]) { params in
            let p1 = try params.parameterAt(0, as: P1.self)
            let p2 = try params.parameterAt(1, as: P2.self)
            let p3 = try params.parameterAt(2, as: P3.self)
            let p4 = try params.parameterAt(3, as: P4.self)
            let p5 = try params.parameterAt(4, as: P5.self)
            let p6 = try params.parameterAt(5, as: P6.self)
            return instatiator(p1, p2, p3, p4, p5, p6)
        }
        
        self.init(.type(T.self, supertype: supertype), dependencyInstantiator)
    }
    
    init<P1, P2, P3, P4, P5, P6, T>(_ dependencyLocator: DependencyLocator, _ instatiator: @escaping (P1, P2, P3, P4, P5, P6) -> T) {
        let dependencyInstantiator = DependencyInstantiator<T>(parameterTypes: [P1.self, P2.self, P3.self, P4.self, P5.self, P6.self]) { params in
            let p1 = try params.parameterAt(0, as: P1.self)
            let p2 = try params.parameterAt(1, as: P2.self)
            let p3 = try params.parameterAt(2, as: P3.self)
            let p4 = try params.parameterAt(3, as: P4.self)
            let p5 = try params.parameterAt(4, as: P5.self)
            let p6 = try params.parameterAt(5, as: P6.self)
            return instatiator(p1, p2, p3, p4, p5, p6)
        }
        
        self.init(dependencyLocator, dependencyInstantiator)
    }
}

// MARK: Arity 7 Extensions

public extension Dependency {
    
    init<P1, P2, P3, P4, P5, P6, P7, T>(_ dependencyName: String, _ instatiator: @escaping (P1, P2, P3, P4, P5, P6, P7) -> T) {
        let dependencyInstantiator = DependencyInstantiator<T>(parameterTypes: [P1.self, P2.self, P3.self, P4.self, P5.self, P6.self, P7.self]) { params in
            let p1 = try params.parameterAt(0, as: P1.self)
            let p2 = try params.parameterAt(1, as: P2.self)
            let p3 = try params.parameterAt(2, as: P3.self)
            let p4 = try params.parameterAt(3, as: P4.self)
            let p5 = try params.parameterAt(4, as: P5.self)
            let p6 = try params.parameterAt(5, as: P6.self)
            let p7 = try params.parameterAt(6, as: P7.self)
            return instatiator(p1, p2, p3, p4, p5, p6, p7)
        }
        
        self.init(.name(dependencyName), dependencyInstantiator)
    }
    
    init<P1, P2, P3, P4, P5, P6, P7, T>(_ instatiator: @escaping (P1, P2, P3, P4, P5, P6, P7) -> T) {
        let dependencyInstantiator = DependencyInstantiator<T>(parameterTypes: [P1.self, P2.self, P3.self, P4.self, P5.self, P6.self, P7.self]) { params in
            let p1 = try params.parameterAt(0, as: P1.self)
            let p2 = try params.parameterAt(1, as: P2.self)
            let p3 = try params.parameterAt(2, as: P3.self)
            let p4 = try params.parameterAt(3, as: P4.self)
            let p5 = try params.parameterAt(4, as: P5.self)
            let p6 = try params.parameterAt(5, as: P6.self)
            let p7 = try params.parameterAt(6, as: P7.self)
            return instatiator(p1, p2, p3, p4, p5, p6, p7)
        }
        
        self.init(.type(T.self), dependencyInstantiator)
    }
    
    init<P1, P2, P3, P4, P5, P6, P7, T, S>(implementing supertype: S.Type, _ instatiator: @escaping (P1, P2, P3, P4, P5, P6, P7) -> T) {
        let dependencyInstantiator = DependencyInstantiator<T>(parameterTypes: [P1.self, P2.self, P3.self, P4.self, P5.self, P6.self, P7.self]) { params in
            let p1 = try params.parameterAt(0, as: P1.self)
            let p2 = try params.parameterAt(1, as: P2.self)
            let p3 = try params.parameterAt(2, as: P3.self)
            let p4 = try params.parameterAt(3, as: P4.self)
            let p5 = try params.parameterAt(4, as: P5.self)
            let p6 = try params.parameterAt(5, as: P6.self)
            let p7 = try params.parameterAt(6, as: P7.self)
            return instatiator(p1, p2, p3, p4, p5, p6, p7)
        }
        
        self.init(.type(T.self, supertype: supertype), dependencyInstantiator)
    }
    
    init<P1, P2, P3, P4, P5, P6, P7, T>(_ dependencyLocator: DependencyLocator, _ instatiator: @escaping (P1, P2, P3, P4, P5, P6, P7) -> T) {
        let dependencyInstantiator = DependencyInstantiator<T>(parameterTypes: [P1.self, P2.self, P3.self, P4.self, P5.self, P6.self, P7.self]) { params in
            let p1 = try params.parameterAt(0, as: P1.self)
            let p2 = try params.parameterAt(1, as: P2.self)
            let p3 = try params.parameterAt(2, as: P3.self)
            let p4 = try params.parameterAt(3, as: P4.self)
            let p5 = try params.parameterAt(4, as: P5.self)
            let p6 = try params.parameterAt(5, as: P6.self)
            let p7 = try params.parameterAt(6, as: P7.self)
            return instatiator(p1, p2, p3, p4, p5, p6, p7)
        }
        
        self.init(dependencyLocator, dependencyInstantiator)
    }
}



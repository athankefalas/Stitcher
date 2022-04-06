//
//  ThrowingFunctionInvocation.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 6/3/22.
//

import Foundation

/// A type that locates a throwing function from the active dependency graph and provides a way to invoke it.
open class ThrowingFunctionInvocation<P, R>: UnsafeSyntheticMember {
    
    private let functionInvocation: () throws -> R
    
    public init(_ name: String) where P == Void {
        warnUnsafeSynthticUsage(function: name)
        
        let function: () throws -> R = try! DependencyGraph.active.injectFunction(named: name)
        
        self.functionInvocation = {
            try function()
        }
    }
    
    public init(_ name: String, _ p1: P) {
        warnUnsafeSynthticUsage(function: name)
        
        let function: (P) throws -> R = try! DependencyGraph.active.injectFunction(named: name)
        
        self.functionInvocation = {
            try function(p1)
        }
    }
    
    public init<P1, P2>(_ name: String, _ p1: P1, _ p2: P2) where P == (P1, P2) {
        warnUnsafeSynthticUsage(function: name)
        
        let function: (P1, P2) throws -> R = try! DependencyGraph.active.injectFunction(named: name)
        
        self.functionInvocation = {
            try function(p1, p2)
        }
    }
    
    public init<P1, P2, P3>(_ name: String, _ p1: P1, _ p2: P2, _ p3: P3) where P == (P1, P2, P3) {
        warnUnsafeSynthticUsage(function: name)
        
        let function: (P1, P2, P3) throws -> R = try! DependencyGraph.active.injectFunction(named: name)
        
        self.functionInvocation = {
            try function(p1, p2, p3)
        }
    }
    
    public init<P1, P2, P3, P4>(_ name: String, _ p1: P1, _ p2: P2, _ p3: P3, _ p4: P4) where P == (P1, P2, P3, P4) {
        warnUnsafeSynthticUsage(function: name)
        
        let function: (P1, P2, P3, P4) throws -> R = try! DependencyGraph.active.injectFunction(named: name)
        
        self.functionInvocation = {
            try function(p1, p2, p3, p4)
        }
    }
    
    public init<P1, P2, P3, P4, P5>(_ name: String, _ p1: P1, _ p2: P2, _ p3: P3, _ p4: P4, _ p5: P5) where P == (P1, P2, P3, P4, P5) {
        warnUnsafeSynthticUsage(function: name)
        
        let function: (P1, P2, P3, P4, P5) throws -> R = try! DependencyGraph.active.injectFunction(named: name)
        
        self.functionInvocation = {
            try function(p1, p2, p3, p4, p5)
        }
    }
    
    public init<P1, P2, P3, P4, P5, P6>(_ name: String, _ p1: P1, _ p2: P2, _ p3: P3, _ p4: P4, _ p5: P5, _ p6: P6) where P == (P1, P2, P3, P4, P5, P6) {
        warnUnsafeSynthticUsage(function: name)
        
        let function: (P1, P2, P3, P4, P5, P6) throws -> R = try! DependencyGraph.active.injectFunction(named: name)
        
        self.functionInvocation = {
            try function(p1, p2, p3, p4, p5, p6)
        }
    }
    
    public init<P1, P2, P3, P4, P5, P6, P7>(_ name: String, _ p1: P1, _ p2: P2, _ p3: P3, _ p4: P4, _ p5: P5, _ p6: P6, _ p7: P7) where P == (P1, P2, P3, P4, P5, P6, P7) {
        warnUnsafeSynthticUsage(function: name)
        
        let function: (P1, P2, P3, P4, P5, P6, P7) throws -> R = try! DependencyGraph.active.injectFunction(named: name)
        
        self.functionInvocation = {
            try function(p1, p2, p3, p4, p5, p6, p7)
        }
    }
    
    open func invoke() throws -> R {
        return try functionInvocation()
    }
}

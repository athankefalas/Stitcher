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
//  TestTypes.swift
//  
//
//  Created by Athanasios Kefalas on 8/3/22.
//

import Foundation
import Stitcher

// MARK: General Use

class Alpha: PostInstantiationNotified, PreInjectionNotified {
    
    enum Actions {
        case postInstantiationNotification
        case preInjetionNotification
    }
    
    var string: String?
    
    private(set) var actions: [Actions] = []
    
    func didInstantiate() {
        actions.append(.postInstantiationNotification)
    }
    
    func willInject() {
        actions.append(.preInjetionNotification)
    }
    
}

// MARK: Testing Injection

protocol TestDependencyProtocol {
    func getValue() -> String
}

struct TestDependencyStaging: TestDependencyProtocol {
    static let value = "Staging"
    
    func getValue() -> String {
        return Self.value
    }
}

struct TestDependencyProduction: TestDependencyProtocol {
    static let value = "Production"
    
    func getValue() -> String {
        return Self.value
    }
}


struct TestTypeP0: Instantiable {}

struct TestTypeP1 {
    let param1: String
}

struct TestTypeP2 {
    let param1: String
    let param2: Int
}

struct TestTypeP3 {
    let param1: String
    let param2: Int
    let param3: String
}

struct TestTypeP4 {
    let param1: String
    let param2: Int
    let param3: String
    let param4: Int
}

struct TestTypeP5 {
    let param1: String
    let param2: Int
    let param3: String
    let param4: Int
    let param5: String
}

struct TestTypeP6 {
    let param1: String
    let param2: Int
    let param3: String
    let param4: Int
    let param5: String
    let param6: Int
}

struct TestTypeP7 {
    let param1: String
    let param2: Int
    let param3: String
    let param4: Int
    let param5: String
    let param6: Int
    let param7: String
}

// MARK: Testing Type Hierarchy

protocol Supertype {
    func randomInt() -> Int
}

struct Basetype: Supertype {
    
    func randomInt() -> Int {
        return .random(in: 0...100)
    }
}

protocol TypePrinting {
    func printType()
}

struct StructTypePrinting: TypePrinting {
    func printType() {
        print("\(Self.self)")
    }
}

class ClassTypePrinting: TypePrinting {
    func printType() {
        print("\(Self.self)")
    }
}

final class FinalClassTypePrinting: ClassTypePrinting {
    override func printType() {
        print("\(Self.self)")
    }
}

// MARK: Testing Synthetic Types

final class SyntheticTestingType: UnsafeSyntheticType {
    
    static let propertyName = "syntheticProperty"
    static let functionName = "syntheticFunction"
    static let otherFunctionName = "syntheticOtherFunction"
    
    @SyntheticProperty(propertyName)
    var property: String
    
    
    @SyntheticFunction
    func function() -> String {
        FunctionInvocation<Void, String>(SyntheticTestingType.functionName)
    }
    
    @SyntheticFunction
    func otherFunction(parameter1: String, parameter2: Int) -> String {
        FunctionInvocation<(String, Int), String>(SyntheticTestingType.otherFunctionName, parameter1, parameter2)
    }
}

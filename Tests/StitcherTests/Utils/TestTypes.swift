//
//  TestTypes.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 8/3/22.
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

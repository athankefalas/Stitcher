//
//  TypeCastingError.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 25/12/21.
//

import Foundation

public struct TypeCastingError: Error, CustomStringConvertible {
    public let instanceType: String
    public let targetType: String
    
    public var description: String {
        "Failed to cast instance of type '\(instanceType)' to type '\(targetType)'."
    }
    
    public init<Instance, T>(of instance: Instance, toType targetType: T.Type = T.self) {
        self.instanceType = "\(type(of: instance))"
        self.targetType = "\(targetType)"
    }
}

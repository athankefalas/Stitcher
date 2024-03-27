//
//  AutoregisterableDependencyCodeGenerator.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 26/3/24.
//

import Foundation

public struct AutoregisterableDependencyCodeGenerator {
    
    public enum Arguments: String, CaseIterable {
        case dependencyLocator = "locator"
        case dependencyScope = "scope"
        case dependencyEagerness = "eagerness"
    }
    
    public init() {}
    
    public func autoregistrationContainerPropertyName() -> String {
        return "dependencyRegistration"
    }
    
    public func autoregistrationContainerOrderedArguments() -> [Arguments] {
        return Arguments.allCases
    }
    
    public func generateAutoregistrationContainerExpression(
        typeName: String
    ) -> String {
        return "GeneratedDependencyRegistration<\(typeName)>"
    }
}

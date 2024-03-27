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
    
    init() {}
    
    func orderedArguments() -> [Arguments] {
        return Arguments.allCases
    }
    
    func generateAutoregistrationContainerExpression(
        typeName: String
    ) -> String {
        return "GeneratedDependencyRegistration<\(typeName)>"
    }
}

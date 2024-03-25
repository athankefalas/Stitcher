//
//  NameInjectionCodeGenerator.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 25/3/24.
//

import Foundation

struct NameInjectionCodeGenerator: InjectionCodeGenerator {
    
    init() {}
    
    func generateInjectionExpression(
        parameterName: String?,
        parameterTypeName: String
    ) -> String {
        
        if let parameterName {
            return "try! DependencyGraph.inject(byName: \(parameterName))"
        }
        
        return "try! DependencyGraph.inject(byType: \(parameterTypeName).self)"
    }
}

//
//  TypeInjectionCodeGenerator.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 25/3/24.
//

import Foundation

struct TypeInjectionCodeGenerator: InjectionCodeGenerator {
    
    init() {}
    
    func generateInjectionExpression(
        parameterName: String?,
        parameterTypeName: String
    ) -> String {
        return "try! DependencyGraph.inject(byType: \(parameterTypeName).self)"
    }
}

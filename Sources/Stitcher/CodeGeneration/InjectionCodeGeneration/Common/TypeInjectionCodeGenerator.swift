//
//  TypeInjectionCodeGenerator.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 25/3/24.
//

import Foundation

struct TypeInjectionCodeGenerator: InjectionCodeGenerator {
    
    init() {}
    
    func generateInjectionCode(
        parameterName: String?,
        parameterType: String
    ) -> String {
        return "try! DependencyGraph.inject(byType: \(parameterType).self)"
    }
}

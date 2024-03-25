//
//  TestInjectionCodeGenerator.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 25/3/24.
//

import Foundation

struct TestInjectionCodeGenerator: InjectionCodeGenerator {
    
    func generateInjectionExpression(
        parameterName: String?,
        parameterTypeName: String
    ) -> String {
        "GENERATED_\(parameterTypeName)"
    }
}

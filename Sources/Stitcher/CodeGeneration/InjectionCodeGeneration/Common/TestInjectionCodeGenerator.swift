//
//  TestInjectionCodeGenerator.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 25/3/24.
//

import Foundation

struct TestInjectionCodeGenerator: InjectionCodeGenerator {
    
    func generateInjectionCode(
        parameterName: String?,
        parameterType: String
    ) -> String {
        "Generated_\(parameterType)"
    }
}

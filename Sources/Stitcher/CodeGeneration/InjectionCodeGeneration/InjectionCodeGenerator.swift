//
//  InjectionCodeGenerator.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 25/3/24.
//

import Foundation

public protocol InjectionCodeGenerator {
    
    func generateInjectionExpression(
        parameterName: String?,
        parameterTypeName: String
    ) -> String
}

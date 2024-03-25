//
//  InjectionCodeGenerator.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 25/3/24.
//

import Foundation

public protocol InjectionCodeGenerator {
    
    func generateInjectionCode(
        parameterName: String?,
        parameterType: String
    ) -> String
}

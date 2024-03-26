//
//  AutoregisterableDependencyCodeGenerator.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 26/3/24.
//

import Foundation

public protocol AutoregisterableDependencyCodeGenerator {
    
    func generateAutoregistrationContainerExpression(
        typeName: String
    ) -> String
}

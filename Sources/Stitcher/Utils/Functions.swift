//
//  Functions.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 27/2/24.
//

import Foundation

func fatal(
    _ error: InjectionError,
    file: StaticString,
    line: UInt
) -> Never {
    
    let failureMessage: String
    
    if let recoverySuggestion = error.recoverySuggestion {
        failureMessage = "InjectionError: \(error.description). Recovery: \(recoverySuggestion)"
    } else {
        failureMessage = "InjectionError: \(error.description)."
    }
    
    return preconditionFailure(failureMessage, file: file, line: line)
}

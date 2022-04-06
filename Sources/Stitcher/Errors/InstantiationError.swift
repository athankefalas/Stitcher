//
//  InstantiationError.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 25/12/21.
//

import Foundation

public enum InstantiationError: Error {
    case incorrectParameterCount
    case incorrectParameterType(TypeCastingError)
    case instantiationFailed
}

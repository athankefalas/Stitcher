//
//  RawThreadKeyError.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 12/3/24.
//

import Foundation

struct RawThreadKeyError: Error {
    
    enum Operation {
        case writeValue
    }
    
    enum WriteValueCode: Int, RawRepresentable {
        case success = 0
    }
    
    private let code: Int
    private let operation: Operation
    
    private init(code: Int, operation: Operation) {
        self.code = code
        self.operation = operation
    }
    
    static func writeValueError(converting status: Int32) -> RawThreadKeyError? {
        let status = Int(status)
        let error = RawThreadKeyError(code: status, operation: .writeValue)
        
        if let writeValueCode = WriteValueCode(rawValue: status) {
            return writeValueCode == .success ? .none : error
        }
        
        return error
    }
}

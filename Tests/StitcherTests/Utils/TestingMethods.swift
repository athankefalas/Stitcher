//
//  TestingMethods.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 8/3/22.
//

import Foundation
import XCTest


struct TestFailedError: Error{
    let message: String
}

func assertSucceeds<T>(_ expression: @escaping () throws -> T, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) throws -> T {
    
    switch Result(catching: expression) {
    case .success(let result):
        return result
    case .failure(let error):
        let message = message()
        let failureMessage = message.isEmpty ? "expected expression not to throw error \"\(error)\"." : message
        
        XCTFail(failureMessage, file: file, line: line)
        throw error
    }
}

func assertFails<T>(_ expression: @escaping () throws -> T, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) throws {
    
    switch Result(catching: expression) {
    case .success(_):
        let message = message()
        let failureMessage = message.isEmpty ? "expected expression to throw error." : message
        
        XCTFail(failureMessage, file: file, line: line)
    case .failure(_):
        break
    }
}

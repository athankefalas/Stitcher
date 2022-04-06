//
// MIT License
//
// Copyright (c) 2022 Athanasios Kefalas
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
//
//  TestingMethods.swift
//  
//
//  Created by Athanasios Kefalas on 8/3/22.
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

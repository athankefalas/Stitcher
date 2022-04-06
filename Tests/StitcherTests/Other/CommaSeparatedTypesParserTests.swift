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
//  CommaSeparatedTypesParserTests.swift
//  
//
//  Created by Athanasios Kefalas on 22/3/22.
//

import XCTest
@testable import Stitcher

class CommaSeparatedTypesParserTests: XCTestCase {

    func test_CommaSeparatedTypesParser_parsesOneType() throws {
        let sut = CommaSeparatedTypesParser()
        
        let typesString = "String"
        let expectedTypes = [
            "String"
        ]
        
        XCTAssertEqual(sut.parseTypes(from: typesString), expectedTypes)
    }
    
    func test_CommaSeparatedTypesParser_parsesTwoTypes() throws {
        let sut = CommaSeparatedTypesParser()
        
        let typesString = "String,Int"
        let expectedTypes = [
            "String",
            "Int"
        ]
        
        XCTAssertEqual(sut.parseTypes(from: typesString), expectedTypes)
    }
    
    func test_CommaSeparatedTypesParser_parsesComplexGenericTypesExpression() throws {
        let sut = CommaSeparatedTypesParser()
        
        let typesString = "GenericType<Double,Int>,GenericType<SubType<String>,(Int,String)>,GenericType<(Int,String),(Int,Subtype<String>)>"
        let expectedTypes = [
            "GenericType<Double,Int>",
            "GenericType<SubType<String>,(Int,String)>",
            "GenericType<(Int,String),(Int,Subtype<String>)>"
        ]
        
        XCTAssertEqual(sut.parseTypes(from: typesString), expectedTypes)
    }
    
    func test_CommaSeparatedTypesParser_parsesComplexTypesExpression() throws {
        let sut = CommaSeparatedTypesParser()
        
        let typesString = "String,Int,(Float,String),(String) -> (Int),GenericType<Double,Int>"
        let expectedTypes = [
            "String",
            "Int",
            "(Float,String)",
            "(String) -> (Int)",
            "GenericType<Double,Int>"
        ]
        
        XCTAssertEqual(sut.parseTypes(from: typesString), expectedTypes)
    }

}

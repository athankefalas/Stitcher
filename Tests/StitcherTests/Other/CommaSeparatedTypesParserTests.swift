//
//  CommaSeparatedTypesParserTests.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 22/3/22.
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

//
//  ArraySlicingTests.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 15/3/24.
//

import XCTest
@testable import Stitcher

final class ArraySlicingTests: XCTestCase {

    func test_slicing_even() {
        let array = [1, 2, 3, 4]
        let s1 = array.slice(at: 0, outOf: 2)
        let s2 = array.slice(at: 1, outOf: 2)
        XCTAssert(s1 == [1, 2])
        XCTAssert(s2 == [3, 4])
    }
    
    func test_slicing_uneven() {
        let array = [1, 2, 3, 4]
        let s1 = array.slice(at: 0, outOf: 3)
        let s2 = array.slice(at: 1, outOf: 3)
        let s3 = array.slice(at: 2, outOf: 3)
        XCTAssert(s1 == [1])
        XCTAssert(s2 == [2])
        XCTAssert(s3 == [3, 4])
    }
}

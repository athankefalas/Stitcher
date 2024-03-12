//
//  PipelineTests.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 12/3/24.
//

import XCTest
@testable import Stitcher
import Combine
import OpenCombine

final class PipelineTests: XCTestCase {

    func test_subject() {
        let subject = PipelineSubject<Void>()
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2
        
        let subscription = subject
            .sink {
                expectation.fulfill()
            }
        
        subject.send()
        subject.send()
        
        wait(for: [expectation], timeout: 0.1)
        subscription.cancel()
    }
    
    func test_erasedSubject() {
        let subject = PipelineSubject<Void>()
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2
        
        let subscription = subject
            .erasedToAnyPipeline()
            .sink {
                expectation.fulfill()
            }
        
        subject.send()
        subject.send()
        
        wait(for: [expectation], timeout: 0.1)
        subscription.cancel()
    }
    
    func test_combineErasedSubject() {
        let subject = Combine.PassthroughSubject<Void, Never>()
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2
        
        let subscription = subject
            .erasedToAnyPipeline()
            .sink {
                expectation.fulfill()
            }
        
        subject.send()
        subject.send()
        
        wait(for: [expectation], timeout: 0.1)
        subscription.cancel()
    }
    
    func test_openCombineErasedSubject() {
        let subject = OpenCombine.PassthroughSubject<Void, Never>()
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2
        
        let subscription = subject
            .erasedToAnyPipeline()
            .sink {
                expectation.fulfill()
            }
        
        subject.send()
        subject.send()
        
        wait(for: [expectation], timeout: 0.1)
        subscription.cancel()
    }

}

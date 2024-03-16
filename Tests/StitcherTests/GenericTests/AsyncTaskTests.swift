//
//  AsyncTaskTests.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 15/3/24.
//

import XCTest
@testable import Stitcher

final class AsyncTaskTests: XCTestCase {

    override func setUpWithError() throws {
        AsyncTask._prefersSwiftConcurrency = false
    }

    override func tearDownWithError() throws {
        AsyncTask._prefersSwiftConcurrency = true
    }

    func test_asyncTask_runs() {
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2
        
        AsyncTask {
            expectation.fulfill()
        } completion: {
            expectation.fulfill()
        }
        
        wait(for: [expectation])
    }
    
    func test_asyncTask_cancellation() {
        let expectation = XCTestExpectation()
        let cancelled = Atomic(initialValue: false)
        
        let task = AsyncTask { [cancelled] in
            expectation.fulfill()
            
            while !cancelled.wrappedValue {
                continue
            }
            
            guard !AsyncTask.isCancelled else {
                return
            }
            
            XCTFail("Expected task to be cancelled.")
        } completion: {
            XCTFail("Expected a cancelled task to not invoke completion.")
        }
        
        wait(for: [expectation])
        
        task.cancel()
        cancelled.wrappedValue = true
    }
}

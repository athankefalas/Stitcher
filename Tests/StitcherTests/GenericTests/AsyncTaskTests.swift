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
    
    func test_asyncTask_parallelCancellation() {
        let coreCount = (ProcessInfo().processorCount * 3)
        
        for n in 1...coreCount {
            let shouldCancel = n % 2 == 0
            let waiter = Atomic(initialValue: false)
            
            let task = AsyncTask { [waiter] in
                
                while !waiter.wrappedValue {
                    continue
                }
                
                guard !AsyncTask.isCancelled else {
                    if !shouldCancel {
                        XCTFail("Expected task to not be cancelled.")
                    }
                    
                    return
                }
                
                if shouldCancel {
                    XCTFail("Expected task to be cancelled.")
                }
            } completion: {
                if shouldCancel {
                    XCTFail("Expected a cancelled task to not invoke completion.")
                }
            }
                        
            if shouldCancel {
                task.cancel()
            }
            
            waiter.wrappedValue = true
        }
    }
}

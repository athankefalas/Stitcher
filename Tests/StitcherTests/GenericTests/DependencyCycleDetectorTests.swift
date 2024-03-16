//
//  DependencyCycleDetectorTests.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 26/2/24.
//

import XCTest
import Combine
@testable import Stitcher

final class DependencyCycleDetectorTests: XCTestCase {
    
    class Zeta {
        let eta: Eta
                
        init(eta: Eta) {
            self.eta = eta
        }
        
        convenience init() throws {
            let eta: Eta = try DependencyGraph.inject()
            self.init(eta: eta)
        }
    }
    
    class Eta {
        
        let zeta: Zeta
                
        init(zeta: Zeta) {
            self.zeta = zeta
        }
        
        convenience init() throws {
            let zeta: Zeta = try DependencyGraph.inject()
            self.init(zeta: zeta)
        }
    }
    
    let container = DependencyContainer {
        
        Dependency {
            try Zeta()
        }
        
        Dependency {
            try Eta()
        }
    }

    override func setUpWithError() throws {
        DependencyGraph.activate(container)
    }

    override func tearDownWithError() throws {
        DependencyGraph.deactivate(container)
    }
    
    // Positive
    
    func test_dependencyCycleDetection_notTriggered() throws {
        let _ = try withCycleDetection(.name("0")) {
            return 0
        }
        
        let _ = try withCycleDetection(.name("0")) {
            return 0
        }
        
        let count = 100
        let expectation = XCTestExpectation(description: "Injection tasks completed.")
        expectation.expectedFulfillmentCount = count
        expectation.assertForOverFulfill = true
        
        for n in 1...count {
            Task {
                let _ = try withCycleDetection(.name("0")) {
                    return n
                }
                
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    // Negative
    
    func test_dependencyCycleDetection_triggered() throws {
        do {
            let _ = try withCycleDetection(.name("0")) {
                return try withCycleDetection(.name("0")) {
                    return 0
                }
            }
            
            XCTFail("Cyclic dependency error not triggered.")
        } catch {
            let injectionError = InjectionError.wrapping(error)
            
            switch injectionError {
            case .cyclicDependencyReference:
                break
            default:
                throw injectionError
            }
        }
    }
    
    func test_dependencyCycleDetection_viaGraphTriggered() throws {
        do {
            let _: Eta = try DependencyGraph.inject()
            XCTFail("Cyclic dependency error not triggered.")
        } catch {
            let injectionError = InjectionError.wrapping(error)
            
            switch injectionError {
            case .cyclicDependencyReference(let context):
                XCTAssert(context.depth == 3)
            default:
                throw injectionError
            }
        }
    }
    
    // Fallback
    
    func test_dependencyCycleDetectionFallback_key() {
        let one = ThreadIdentifier.current
        let other = ThreadIdentifier.current
        XCTAssert(one == other)
    }
    
    func test_dependencyCycleDetectionFallback_storage() {
        let storage = ThreadStorage<Int>()
        storage.set(1)
        XCTAssert(storage.get() == 1)
    }
    
    // Fallback Positive
    
    func test_dependencyCycleDetectionFallback_notTriggered() throws {
        let _ = try withFallbackCycleDetection(.name("0")) {
            return 0
        }
        
        let _ = try withFallbackCycleDetection(.name("0")) {
            return 0
        }
        
        let count = 100
        let expectation = XCTestExpectation(description: "Injection tasks completed.")
        expectation.expectedFulfillmentCount = count
        expectation.assertForOverFulfill = true
        
        for n in 1...count {
                let _ = try withFallbackCycleDetection(.name("0")) {
                    return n
                }
                
                expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    // Fallback Negative
    
    func test_dependencyCycleDetectionFallback_triggered() throws {
        do {
            let _ = try withFallbackCycleDetection(.name("0")) {
                return try withFallbackCycleDetection(.name("0")) {
                    return 0
                }
            }
            
            XCTFail("Cyclic dependency error not triggered.")
        } catch {
            let injectionError = InjectionError.wrapping(error)
            
            switch injectionError {
            case .cyclicDependencyReference:
                break
            default:
                throw injectionError
            }
        }
    }
}

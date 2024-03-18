//
//  GenericTests.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 27/2/24.
//

import XCTest
@testable import Stitcher

final class GenericTests: XCTestCase {
    
    class Service: PostInstantiationAware {
        private(set) var isActive: Bool
        
        init(isActive: Bool = false) {
            self.isActive = isActive
        }
        
        func didInstantiate() {
            isActive = true
        }
    }
    
    let container = DependencyContainer {
        Service()
    }
    
    override func setUpWithError() throws {
        DependencyGraph.activate(container)
    }

    override func tearDownWithError() throws {
        DependencyGraph.deactivate(container)
    }
    
    func test_postInstantiationAware_isCalled() throws {
        @Injected var service: Service
        XCTAssert(service.isActive)
    }
    
    func delay(_ delayInterval: TimeInterval) async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.asyncAfter(deadline: .now() + delayInterval) {
                continuation.resume()
            }
        }
    }
}

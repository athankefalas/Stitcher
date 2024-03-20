//
//  GenericTests.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 27/2/24.
//

import XCTest
@testable import Stitcher

final class GenericTests: XCTestCase {
    
    struct Component: PostInstantiationAware {
        
        private var _isActive: Reference<Bool>
        
        var isActive: Bool {
            _isActive.wrappedValue
        }
        
        init(isActive: Bool = false) {
            self._isActive = Reference(wrappedValue: isActive)
        }
        
        func didInstantiate() {
            _isActive.wrappedValue = true
        }
    }
    
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
        
        Component()
    }
    
    override func setUpWithError() throws {
        DependencyGraph.activate(container)
    }

    override func tearDownWithError() throws {
        DependencyGraph.deactivate(container)
    }
    
    func test_postInstantiationAware_isCalled() async throws {
        let service: Service = try DependencyGraph.inject()
        let component: Component = try DependencyGraph.inject()
        
        await delay(0.02)
        
        XCTAssert(service.isActive)
        XCTAssert(component.isActive)
    }
    
    func delay(_ delayInterval: TimeInterval) async {
        do {
            let nanosecondsPerSecond = TimeInterval(1_000_000_000)
            let nanosecondsDelayInterval = UInt64(delayInterval * nanosecondsPerSecond)
            try await Task.sleep(nanoseconds: nanosecondsDelayInterval)
        } catch {}
    }
}

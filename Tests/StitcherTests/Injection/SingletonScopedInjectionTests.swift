//
//  SingletonScopedInjectionTests.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 22/3/22.
//

import XCTest
import Stitcher

class SingletonScopedInjectionTests: XCTestCase {
    
    private static let alpha = Alpha()
    
    override func setUpWithError() throws {
        try DependencyGraph.activate {
            DependencyContainer("Tests") {
                Dependency(Self.alpha)
            }
        }
    }
    
    // MARK: Happy
    
    func test_injection_ofSingleton() throws {
        let sut = DependencyGraph.active
        let reference: Alpha = try assertSucceeds {
            try sut.inject()
        }
        
        let otherReference: Alpha = try assertSucceeds {
            try sut.inject()
        }
        
        let sharedValue = "Test"
        reference.string = sharedValue
        
        XCTAssertEqual(reference.string, otherReference.string)
    }
}

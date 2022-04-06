//
//  InjectionNotificationTests.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 22/3/22.
//

import XCTest
import Stitcher

class InjectionNotificationTests: XCTestCase {

    private static let alpha = Alpha()
    
    override func setUpWithError() throws {
        try DependencyGraph.activate {
            DependencyContainer("Tests") {
                Dependency("A", Alpha.init)
                Dependency(Self.alpha)
            }
        }
    }
    
    // MARK: Happy
    
    func test_injection_notificationsInvoked() throws {
        let sut = DependencyGraph.active
        let instance: Alpha = try assertSucceeds {
            try sut.inject(named: "A")
        }
        
        XCTAssertEqual(instance.actions, [
            .postInstantiationNotification,
            .preInjetionNotification])
    }
    
    func test_injection_notificationsInvokedInSingleton() throws {
        let sut = DependencyGraph.active
        let instance: Alpha = try assertSucceeds {
            try sut.inject()
        }
        
        let _: Alpha = try assertSucceeds {
            try sut.inject()
        }
        
        XCTAssertEqual(instance.actions, [
            .postInstantiationNotification,
            .preInjetionNotification,
            .postInstantiationNotification,
            .preInjetionNotification])
    }

}

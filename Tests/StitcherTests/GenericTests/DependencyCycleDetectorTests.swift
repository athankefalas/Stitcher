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
            let eta: Eta = try DependencyGraph.injectDependency()
            self.init(eta: eta)
        }
    }
    
    class Eta {
        
        init() {}
    }
    
    let container = DependencyContainer {
        try! Zeta()
        
        Eta()
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
        
        Task {
            let _ = try withCycleDetection(.name("0")) {
                return 0
            }
        }
        
        Task {
            let _ = try withCycleDetection(.name("0")) {
                return 0
            }
        }
    }
    
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
            case .cyclicDependencyReference(let dependencyContext):
                break
            default:
                throw injectionError
            }
        }
    }
}

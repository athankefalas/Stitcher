//
//  NameInjectionTests.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 26/2/24.
//

import XCTest
import Stitcher

final class NameInjectionTests: XCTestCase {
    
    enum Names: String {
        case alpha
        case beta
        case otherAlpha
        case gamma
    }
    
    let container = DependencyContainer {
        Dependency {
            Alpha()
        }
        .named(Names.alpha)
        
        Dependency {
            Beta()
        }
        .named(Names.beta)
        
        Dependency {
            Alpha()
        }
        .named(Names.otherAlpha)
    }
    
    override func setUpWithError() throws {
        DependencyGraph.activate(container)
    }

    override func tearDownWithError() throws {
        DependencyGraph.deactivate(container)
    }
    
    // Positive
    
    func test_injectionByName_findsDependency() throws {
        let dependency: Alpha = try DependencyGraph.inject(byName: Names.alpha)
        XCTAssert(dependency.value == Alpha().value)
    }
    
    func test_injectionByName_findsOtherDependency() throws {
        let dependency: Beta = try DependencyGraph.inject(byName: Names.beta)
        XCTAssert(dependency.value == Beta().value)
    }
    
    func test_injectionByName_aliasedRegistrationsNotOverwritten() throws {
        let dependency: Alpha = try DependencyGraph.inject(byName: Names.alpha)
        let aliasedDependency: Alpha = try DependencyGraph.inject(byName: Names.otherAlpha)
        XCTAssert(dependency.value == Alpha().value)
        XCTAssert(aliasedDependency.value == Alpha().value)
        XCTAssert(dependency !== aliasedDependency)
    }
    
    // Negative
    
    func test_injectionByName_registredDependencyNotDiscoverableByType() throws {
        do {
            let _: Alpha = try DependencyGraph.inject()
            XCTFail("Expected dependency to not be registred.")
        } catch {
            let injectionError = error as! InjectionError
            
            switch injectionError {
            case .missingDependency(let dependencyContext):
                XCTAssert(dependencyContext == .type("Alpha"))
            default:
                XCTFail("Expected missing dependency error.")
            }
        }
    }
    
    func test_injectionByName_registredDependencyNotDiscoverableByValue() throws {
        do {
            let _: Alpha = try DependencyGraph.inject(byValue: Names.alpha)
            XCTFail("Expected dependency to not be registred.")
        } catch {
            let injectionError = error as! InjectionError
            
            switch injectionError {
            case .missingDependency(let dependencyContext):
                XCTAssert(dependencyContext == .value(Names.alpha))
            default:
                XCTFail("Expected missing dependency error.")
            }
        }
    }
    
    func test_injectionByName_unregistredDependencyThrows() throws {
        do {
            let _: Gamma = try DependencyGraph.inject(byName: Names.gamma)
            XCTFail("Expected dependency to not be registred.")
        } catch {
            let injectionError = error as! InjectionError
            
            switch injectionError {
            case .missingDependency(let dependencyContext):
                XCTAssert(dependencyContext == .name("gamma"))
            default:
                XCTFail("Expected missing dependency error.")
            }
        }
    }
    
    func test_injectionByName_incompatibleTypeDependencyThrows() throws {
        do {
            let _: Gamma = try DependencyGraph.inject(byName: Names.alpha)
            XCTFail("Expected dependency to not be registred.")
        } catch {
            let injectionError = error as! InjectionError
            
            switch injectionError {
            case .mismatchedDependencyType:
                break
            default:
                XCTFail("Expected missing dependency error.")
            }
        }
    }
}

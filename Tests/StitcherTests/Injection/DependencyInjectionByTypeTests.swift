//
//  DependencyInjectionByTypeTests.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 9/3/22.
//

import XCTest
import Stitcher

class DependencyInjectionByTypeTests: XCTestCase {

    override func setUpWithError() throws {
        try DependencyGraph.activate {
            DependencyContainer("Tests") {
                Dependency(TestTypeP0.self)
                Dependency(TestTypeP1.init)
                Dependency(TestTypeP2.init)
                Dependency(TestTypeP3.init)
                Dependency(TestTypeP4.init)
                Dependency(TestTypeP5.init)
                Dependency(TestTypeP6.init)
                Dependency(TestTypeP7.init)
                
                Dependency(implementing: Supertype.self, Basetype.init)
                
                Dependency(implementing: TypePrinting.self, StructTypePrinting.init)
                Dependency(implementing: TypePrinting.self, ClassTypePrinting.init)
                
                Dependency(
                    .type(
                        FinalClassTypePrinting.self,
                        supertypes: ClassTypePrinting.self, TypePrinting.self
                    ),
                    FinalClassTypePrinting.init
                )
            }
        }
    }
    
    // MARK: Happy
    
    func test_injection_bySupertype() throws {
        let sut = DependencyGraph.active
        let _: Supertype = try assertSucceeds {
            try sut.inject()
        }
    }
    
    func test_injection_allBySupertype() throws {
        let sut = DependencyGraph.active
        let dependencies: [ClassTypePrinting] = try assertSucceeds {
            try sut.injectAll()
        }
        
        XCTAssertEqual(dependencies.count, 2)
    }
    
    func test_injection_allByProtocolSupertype() throws {
        let sut = DependencyGraph.active
        let dependencies: [TypePrinting] = try assertSucceeds {
            try sut.injectAll()
        }
        
        XCTAssertEqual(dependencies.count, 3)
    }

    func test_injection_withNoArgs() throws {
        let sut = DependencyGraph.active
        let _: TestTypeP0 = try assertSucceeds {
            try sut.inject()
        }
    }
    
    func test_injection_withOneArg() throws {
        let sut = DependencyGraph.active
        let instance: TestTypeP1 = try assertSucceeds {
            try sut.inject(parameters: ["1"])
        }
        
        XCTAssertEqual(instance.param1, "1")
    }
    
    func test_injection_withTwoArgs() throws {
        let sut = DependencyGraph.active
        let instance: TestTypeP2 = try assertSucceeds {
            try sut.inject(parameters: ["1", 2])
        }
        
        XCTAssertEqual(instance.param1, "1")
        XCTAssertEqual(instance.param2, 2)
    }
    
    func test_injection_withThreeArgs() throws {
        let sut = DependencyGraph.active
        let instance: TestTypeP3 = try assertSucceeds {
            try sut.inject(parameters: ["1", 2, "3"])
        }
        
        XCTAssertEqual(instance.param1, "1")
        XCTAssertEqual(instance.param2, 2)
        XCTAssertEqual(instance.param3, "3")
    }
    
    func test_injection_withFourArgs() throws {
        let sut = DependencyGraph.active
        let instance: TestTypeP4 = try assertSucceeds {
            try sut.inject(parameters: ["1", 2, "3", 4])
        }
        
        XCTAssertEqual(instance.param1, "1")
        XCTAssertEqual(instance.param2, 2)
        XCTAssertEqual(instance.param3, "3")
        XCTAssertEqual(instance.param4, 4)
    }
    
    func test_injection_withFiveArgs() throws {
        let sut = DependencyGraph.active
        let instance: TestTypeP5 = try assertSucceeds {
            try sut.inject(parameters: ["1", 2, "3", 4, "5"])
        }
        
        XCTAssertEqual(instance.param1, "1")
        XCTAssertEqual(instance.param2, 2)
        XCTAssertEqual(instance.param3, "3")
        XCTAssertEqual(instance.param4, 4)
        XCTAssertEqual(instance.param5, "5")
    }
    
    func test_injection_withSixArgs() throws {
        let sut = DependencyGraph.active
        let instance: TestTypeP6 = try assertSucceeds {
            try sut.inject(parameters: ["1", 2, "3", 4, "5", 6])
        }
        
        XCTAssertEqual(instance.param1, "1")
        XCTAssertEqual(instance.param2, 2)
        XCTAssertEqual(instance.param3, "3")
        XCTAssertEqual(instance.param4, 4)
        XCTAssertEqual(instance.param5, "5")
        XCTAssertEqual(instance.param6, 6)
    }
    
    func test_injection_withSevenArgs() throws {
        let sut = DependencyGraph.active
        let instance: TestTypeP7 = try assertSucceeds {
            try sut.inject(parameters: ["1", 2, "3", 4, "5", 6, "7"])
        }
        
        XCTAssertEqual(instance.param1, "1")
        XCTAssertEqual(instance.param2, 2)
        XCTAssertEqual(instance.param3, "3")
        XCTAssertEqual(instance.param4, 4)
        XCTAssertEqual(instance.param5, "5")
        XCTAssertEqual(instance.param6, 6)
        XCTAssertEqual(instance.param7, "7")
    }
    
    

}

//
//  DependencyInjectionByNameTests.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 8/3/22.
//

import XCTest
import Stitcher

class DependencyInjectionByNameTests: XCTestCase {

    static var isStaging = Bool.random()
    
    override func setUpWithError() throws {
        try DependencyGraph.activate {
            DependencyContainer("Tests") {
                Dependency("P0", TestTypeP0.init)
                Dependency("P1", TestTypeP1.init)
                Dependency("P2", TestTypeP2.init)
                Dependency("P3", TestTypeP3.init)
                Dependency("P4", TestTypeP4.init)
                Dependency("P5", TestTypeP5.init)
                Dependency("P6", TestTypeP6.init)
                Dependency("P7", TestTypeP7.init)
                
                if Self.isStaging {
                    Dependency("TestDependency", TestDependencyStaging.init)
                } else {
                    Dependency("TestDependency", TestDependencyProduction.init)
                }
                
                for n in 1...1000 {
                    Dependency("N\(n)", TestTypeP0.init)
                }
            } requires: {
                Requirement(.name("P0"))
                Requirement(.name("P1"))
                Requirement(.name("P2"))
                Requirement(.name("P3"))
                Requirement(.name("P4"))
                Requirement(.name("P5"))
                Requirement(.name("P6"))
                Requirement(.name("P7"))
                
                Requirement(.name("TestDependency"))
                
                Requirement(.name("N1"))
                Requirement(.name("N1000"))
            }
        }
    }
    
    // MARK: Happy

    func test_injection_withNoArgs() throws {
        let sut = DependencyGraph.active
        let _: TestTypeP0 = try assertSucceeds {
            try sut.inject(named: "P0")
        }
    }
    
    func test_injection_withOneArg() throws {
        let sut = DependencyGraph.active
        let instance: TestTypeP1 = try assertSucceeds {
            try sut.inject(named: "P1", parameters: ["1"])
        }
        
        XCTAssertEqual(instance.param1, "1")
    }
    
    func test_injection_withTwoArgs() throws {
        let sut = DependencyGraph.active
        let instance: TestTypeP2 = try assertSucceeds {
            try sut.inject(named: "P2", parameters: ["1", 2])
        }
        
        XCTAssertEqual(instance.param1, "1")
        XCTAssertEqual(instance.param2, 2)
    }
    
    func test_injection_withThreeArgs() throws {
        let sut = DependencyGraph.active
        let instance: TestTypeP3 = try assertSucceeds {
            try sut.inject(named: "P3", parameters: ["1", 2, "3"])
        }
        
        XCTAssertEqual(instance.param1, "1")
        XCTAssertEqual(instance.param2, 2)
        XCTAssertEqual(instance.param3, "3")
    }
    
    func test_injection_withFourArgs() throws {
        let sut = DependencyGraph.active
        let instance: TestTypeP4 = try assertSucceeds {
            try sut.inject(named: "P4", parameters: ["1", 2, "3", 4])
        }
        
        XCTAssertEqual(instance.param1, "1")
        XCTAssertEqual(instance.param2, 2)
        XCTAssertEqual(instance.param3, "3")
        XCTAssertEqual(instance.param4, 4)
    }
    
    func test_injection_withFiveArgs() throws {
        let sut = DependencyGraph.active
        let instance: TestTypeP5 = try assertSucceeds {
            try sut.inject(named: "P5", parameters: ["1", 2, "3", 4, "5"])
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
            try sut.inject(named: "P6", parameters: ["1", 2, "3", 4, "5", 6])
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
            try sut.inject(named: "P7", parameters: ["1", 2, "3", 4, "5", 6, "7"])
        }
        
        XCTAssertEqual(instance.param1, "1")
        XCTAssertEqual(instance.param2, 2)
        XCTAssertEqual(instance.param3, "3")
        XCTAssertEqual(instance.param4, 4)
        XCTAssertEqual(instance.param5, "5")
        XCTAssertEqual(instance.param6, 6)
        XCTAssertEqual(instance.param7, "7")
    }
    
    func test_injection_withEnvironmentSwitch() throws {
        let sut = DependencyGraph.active
        let instance: TestDependencyProtocol = try assertSucceeds {
            try sut.inject(named: "TestDependency")
        }
        
        let expectedResult = Self.isStaging ? TestDependencyStaging.value : TestDependencyProduction.value
        let result = instance.getValue()
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_injection_fromLoopDefinition() throws {
        let sut = DependencyGraph.active
        
        for n in 1...1000 {
            let _: TestTypeP0 = try assertSucceeds {
                try sut.inject(named: "N\(n)")
            }
        }
    }
    
    // MARK: Unhappy
    
    func test_injection_withNoArgs_failsDueToInvalidName() throws {
        let sut = DependencyGraph.active
        try assertFails {
            try sut.inject(named: "P0_", type: TestTypeP0.self)
        }
    }

    func test_injection_withNoArgs_failsDueToArg() throws {
        let sut = DependencyGraph.active
        try assertFails {
            try sut.inject(named: "P0", type: TestTypeP0.self, parameters: ["some_parameter"])
        }
    }
    
    func test_injection_withNoArgs_failsDueToType() throws {
        let sut = DependencyGraph.active
        try assertFails {
            try sut.inject(named: "P0", type: TestTypeP1.self)
        }
    }

}

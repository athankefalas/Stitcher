//
//  InjectionCodeGenerators.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 25/3/24.
//

import Foundation

public enum InjectionCodeGenerators {
    
    public struct Name: Hashable, CaseIterable {
        public let rawValue: String
        
        private init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        static let stitcherTest = Name(rawValue: "stitcherTest")
        public static let stitcherByType = Name(rawValue: "stitcherByType")
        public static let stitcherByName = Name(rawValue: "stitcherByName")
        
        public static var allCases: [InjectionCodeGenerators.Name] = [
            .stitcherTest,
            .stitcherByType,
            .stitcherByName
        ]
    }
    
    private static let generators: [Name : any InjectionCodeGenerator] = [
        .stitcherTest : TestInjectionCodeGenerator(),
        .stitcherByType : TypeInjectionCodeGenerator(),
        .stitcherByName : NameInjectionCodeGenerator()
    ]
    
    public static var defaultGenerator: any InjectionCodeGenerator {
        generator(named: .stitcherByType)
    }
    
    public static func generator(named name: Name) -> any InjectionCodeGenerator {
        guard let generator = generators[name] else {
            fatalError("Unknown injection code generator name.")
        }
        
        return generator
    }
}

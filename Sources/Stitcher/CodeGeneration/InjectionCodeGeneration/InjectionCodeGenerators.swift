//
//  InjectionCodeGenerators.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 25/3/24.
//

import Foundation

public enum InjectionCodeGenerators {
    
    public struct Name: Hashable {
        public let rawValue: String
        
        private init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        static let stitcherByType = Name(rawValue: "stitcherByType")
        static let stitcherByName = Name(rawValue: "stitcherByName")
    }
    
    private static let generators: [Name : any InjectionCodeGenerator] = [
        .stitcherByType : TypeInjectionCodeGenerator(),
        .stitcherByName : NameInjectionCodeGenerator()
    ]
    
    public static func generator(named name: Name) -> any InjectionCodeGenerator {
        guard let generator = generators[name] else {
            fatalError("Unknown injection code generator name.")
        }
        
        return generator
    }
}

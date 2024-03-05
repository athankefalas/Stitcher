//
//  TypeName.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 4/2/24.
//

import Foundation

struct TypeName: Hashable {
    
    struct Reader<T>: TypeNameReading {
        
        let typeName: TypeName
        
        init(){
            typeName = TypeName(of: T.self)
        }
    }
    
    let rawValue: String
    let canonicalValue: String
    
    private let allValues: Set<String>
    
    private init() {
        self.init(
            rawValue: mangledName(of: Void.self),
            canonicalValue: "\(Void.self)"
        )
    }
    
    init<T>(of type: T.Type) {
        self.init(
            rawValue: mangledName(of: type),
            canonicalValue: "\(type)"
        )
    }
    
    private init(
        rawValue: String,
        canonicalValue: String
    ) {
        
        self.rawValue = rawValue
        self.canonicalValue = canonicalValue
        self.allValues = [rawValue, canonicalValue]
    }
    
    static let void = TypeName()
    
    static func == (lhs: TypeName, rhs: TypeName) -> Bool {
        return !lhs.allValues.isDisjoint(with: rhs.allValues)
    }
}

protocol TypeNameReading {
    
    var typeName: TypeName { get }
}

fileprivate func mangledName<T>(of type: T.Type) -> String {
    let canonicalTypeName = "\(type)"
    
    if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 6.0, *) {
        return Swift._mangledTypeName(type) ?? canonicalTypeName
    } else {
        // Fallback on earlier versions
        return canonicalTypeName
    }
}

//
//  Priority.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 2/3/22.
//

import Foundation

/// A type that denotes a measure of priority.
/// Valid priority values can be in the range of `0...1000` inclusive.
public struct Priority: Comparable, Equatable, Hashable {
    private let rawValue: UInt
    
    public init(_ rawValue: UInt) {
        self.rawValue = clamp(rawValue, in: 0...1000)
    }
    
    private init(of value: UInt) {
        self.rawValue = value
    }
    
    public static let required = Priority(of: 1000)
    public static let high = Priority(of: 750)
    public static let medium = Priority(of: 500)
    public static let low = Priority(of: 250)
    public static let never = Priority(of: 0)
    
    public static func < (lhs: Priority, rhs: Priority) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

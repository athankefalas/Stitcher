//
//  ThreadValuesKey.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 12/3/24.
//

import Foundation

protocol ThreadValuesKey {
    associatedtype Value
    
    static var rawThreadKey: RawThreadKey<Value> { get }
    static var defaultValue: Value { get }
}



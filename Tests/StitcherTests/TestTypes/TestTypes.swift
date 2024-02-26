//
//  TestTypes.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 26/2/24.
//

import Foundation

protocol TypePrinting {
    
    func printType()
}

extension TypePrinting {
    
    func printType() { print("\(type(of: self))") }
}

protocol LetterClassImplementing {
    
    var value: Int { get }
}

class Letter: TypePrinting, LetterClassImplementing {
    
    var value: Int { -1 }
    
    init(){}
}

class Alpha: Letter {
    
    override var value: Int { 1 }
}

class Beta: Letter {
    
    override var value: Int { 2 }
}

class Gamma: Letter {
    
    override var value: Int { 3 }
}

class Delta: Letter {
    
    override var value: Int { 4 }
}

class Epsilon: Letter {
    
    override var value: Int { 5 }
}

protocol Number: TypePrinting {
    var value: Int { get }
}

struct One: Number, Equatable {
    
    var value: Int = 1
}

struct Two: Number, Equatable {
    
    var value: Int = 2
}

struct Three: Number, Equatable {
    
    var value: Int = 3
}

struct Four: Number, Equatable {
    
    var value: Int = 4
}

struct Values<V: CustomStringConvertible & Hashable>: CustomStringConvertible {
    
    let values: [V]
    
    var description: String {
        values.map(\.description).joined(separator: ", ")
    }
    
    init(values: V...) {
        self.values = values
    }
    
    func printValues() {
        print(self.description)
    }
}

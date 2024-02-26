//
//  DependencyParameters.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 4/2/24.
//

import Foundation

struct DependencyParameters: Hashable {
    
    struct Requirement: Hashable {
        
        private let types: [TypeName]
        
        init() {
            self.types = []
        }
        
        init(types: [TypeName]) {
            self.types = types
        }
        
        init<R, each Parameter: Hashable>(
            from function: (repeat each Parameter) -> R
        ) {
            self.types = Self.readTypeNames(from: function)
        }
        
        func isSatisfied(by parameters: DependencyParameters) -> Bool {
            return types.count == parameters.count && types == parameters.parameterTypes
        }
        
        func parameterType(at index: Int) -> TypeName? {
            guard types.indices.contains(index) else {
                return nil
            }
            
            return types[index]
        }
        
        static let none = Requirement()
        
        private static func readTypeNames<R, each Parameter: Hashable>(
            from function: (repeat each Parameter) -> R
        ) -> [TypeName] {
            
            let tuple = (repeat TypeName.Reader<each Parameter>())
            let mirror = Mirror(reflecting: tuple)
            var tupleValues = mirror
                .children
                .compactMap({ $0.value as? TypeNameReading })
            
            if tupleValues.isEmpty && mirror.displayStyle != .tuple {
                let singleParameter = tuple as! TypeNameReading
                tupleValues = [singleParameter]
            }
            
            return tupleValues.map(\.typeName)
        }
    }
    
    struct Parameter<Value: Hashable>: Hashable {
        let rawValue: Value
        
        init(rawValue: Value) {
            self.rawValue = rawValue
        }
    }
    
    private struct AnyParameter: Hashable {
        
        let type: TypeName
        let erasedValue: AnyHashable
        
        init<Value: Hashable>(erasing value: Value) {
            self.type = TypeName(of: Value.self)
            self.erasedValue = value
        }
    }
    
    private let parameters: [AnyParameter]
    
    var count: Int {
        parameters.count
    }
    
    var parameterTypes: [TypeName] {
        parameters.map(\.type)
    }
    
    var parameterValues: [AnyHashable] {
        parameters.map(\.erasedValue)
    }
    
    init() {
        self.parameters = []
    }
    
    init<each Parameter: Hashable>(
        _ parameter: repeat each Parameter
    ) {
        var parameters = Self.arrayOf(repeat each parameter)
        parameters.removeAll(where: { $0.type == .void })
        
        self.parameters = parameters
    }
    
    private static func arrayOf<each Element: Hashable>(
        _ element: repeat each Element
    ) -> [AnyParameter] {
        
        let tuple = (repeat AnyParameter(erasing: each element))
        let mirror = Mirror(reflecting: tuple)
        var tupleValues = mirror
            .children
            .compactMap({ $0.value as? AnyParameter })
        
        if tupleValues.isEmpty && mirror.displayStyle != .tuple {
            let singleParameter = tuple as! AnyParameter
            tupleValues = [singleParameter]
        }
        
        return tupleValues
    }
    
    func parameter<Value: Hashable>(
        at index: Int,
        as type: Value.Type = Value.self
    ) -> Parameter<Value>? {
        
        guard parameters.indices.contains(index),
              parameters[index].type == TypeName(of: Value.self),
              let parameter = parameters[index].erasedValue as? Value else {
            return nil
        }
        
        return Parameter(rawValue: parameter)
    }
    
    func parameterType(at index: Int) -> TypeName? {
        guard parameterTypes.indices.contains(index) else {
            return nil
        }
        
        return parameterTypes[index]
    }
    
    static let none = DependencyParameters()
}


extension DependencyParameters {
    
    enum ParameterError: Error {
        case mismatchedCount(expected: Int)
        case mismatchedType(index: Int)
    }
    
    struct Repack<V: Hashable> {
        
        let value: V
        
        init(from array: inout [AnyHashable], count: Int) throws {
            let currentCount = array.count
            let currentIndex = count - currentCount
            
            guard array.count > 0 else {
                throw ParameterError.mismatchedCount(expected: count)
            }
            
            guard let value = array.removeFirst() as? V else {
                throw ParameterError.mismatchedType(index: currentIndex)
            }
            
            self.value = value
        }
    }
    
    func withPackedParameters<Value, each Parameter: Hashable>(
        invoke function: (repeat each Parameter) -> Value
    ) throws -> Value {
        
        var parameterValues = parameterValues
        let result = function(
            repeat try Repack<each Parameter>(
                from: &parameterValues,
                count: count
            )
            .value
        )
        
        if !parameterValues.isEmpty {
            throw ParameterError.mismatchedCount(expected: count)
        }
        
        return result
    }
}

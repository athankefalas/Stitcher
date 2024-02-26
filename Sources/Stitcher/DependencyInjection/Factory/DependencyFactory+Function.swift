//
//  DependencyFactory+Function.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 12/2/24.
//

import Foundation

extension DependencyFactory {
    
    static func from<T, each Parameter: Hashable>(
        function: @Sendable @escaping (repeat each Parameter) -> T
    ) -> DependencyFactory {
        
        self.init(
            type: TypeName(of: T.self),
            parameters: DependencyParameters.Requirement(
                from: function
            )
        ) { parameters in
            
            try parameters.withPackedParameters(invoke: function)
        } instanceStorageFactory: { key, instance, scope in
            
            guard let typedValue = instance as? T else {
                return NeverInstanceStorage(key: key).erased()
            }
            
            return InstanceStorageFactory.makeInstanceStorage(
                for: key,
                value: typedValue,
                scope: scope
            )
        }
    }
}

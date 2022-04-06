//
//  Dependency+Instantiable.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 19/3/22.
//

import Foundation

public extension Dependency {
    
    init<T: Instantiable>(_ type: T.Type = T.self) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return T()
        }
        
        self.init(.type(type), dependencyInstantiator)
    }
    
    init<T: Instantiable>(_ dependencyName: String, _ type: T.Type = T.self) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return T()
        }
        
        self.init(.name(dependencyName), dependencyInstantiator)
    }
    
    init<T: Instantiable>(_ dependencyLocator: DependencyLocator, _ type: T.Type = T.self) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return T()
        }
        
        self.init(dependencyLocator, dependencyInstantiator)
    }
    
}

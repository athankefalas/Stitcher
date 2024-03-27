//
//  RegisterableDependency.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 26/3/24.
//

import Foundation

public protocol RegisterableDependency {
    associatedtype SomeDependency
    
    static var dependencyRegistration: GeneratedDependencyRegistration<SomeDependency> { get }
}

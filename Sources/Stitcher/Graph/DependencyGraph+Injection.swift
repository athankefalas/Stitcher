//
// MIT License
//
// Copyright (c) 2022 Athanasios Kefalas
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
//
//  DependencyGraph+Injection.swift
//  
//
//  Created by Athanasios Kefalas on 16/3/22.
//

import Foundation

public extension DependencyGraph {
    
    // MARK: Injection by Type
    
    /// Injects a dependency instance by type
    /// - Parameter type: The type the dependency is required to have
    /// - Returns: An instance of the dependency
    /// - Throws: An error if the dependency is not found or an instance was not successfully created.
    func inject<T>(type: T.Type = T.self) throws -> T {
        return try inject(type: type, parameters: [])
    }
    
    /// Injects a dependency instance by type
    /// - Parameters:
    ///   - type: The type the dependency is required to have
    ///   - parameters: The parameters required by the dependency initializer
    /// - Returns: An instance of the dependency
    /// - Throws: An error if the dependency is not found or an instance was not successfully created.
    func inject<T>(type: T.Type = T.self, parameters: [Any]) throws -> T {
        let typeName = "\(type)"
        let matches = findDependencies(typed: typeName)
        
        guard matches.isNotEmpty else {
            throw InjectionError(cause: DependencyContainerError.missingDependency(typeName))
        }
        
        guard let dependency = determineDependencyByPriority(in: matches) else {
            throw InjectionError(cause: DependencyContainerError.ambiguousDependency(typeName))
        }
        
        do {
            let instance = try dependency.instantiator.instantiate(parameters: parameters)
            let typedInstance = try cast(instance, as: T.self)
            
            if let preInjectionNotifiedInstance = typedInstance as? PreInjectionNotified {
                preInjectionNotifiedInstance.willInject()
            }
            
            return typedInstance
        } catch {
            throw InjectionError(cause: error)
        }
    }
    
    // MARK: Multiple Injection by Type
    
    /// Injects an array of all dependency instances for the given type
    /// - Parameter type: The type the dependencies are required to have
    /// - Returns: An array of dependency instances
    /// - Throws: An error if at least one dependency instance was not successfully created.
    func injectAll<T>(type: T.Type = T.self) throws -> [T] {
        return try injectAll(type: type, parameters: [])
    }
    
    /// Injects an array of all dependency instances for the given type
    /// - Parameters:
    ///   - type: The type the dependencies are required to have
    ///   - parameters: The parameters required by the dependency initializers
    /// - Returns: An array of dependency instances
    /// - Throws: An error if at least one dependency instance was not successfully created.
    func injectAll<T>(type: T.Type = T.self, parameters: [Any]) throws -> [T] {
        let typeName = "\(type)"
        let matches = findDependencies(typed: typeName)
        
        warn("Attempting to inject multiple dependencies. This action requires that all dependencies can be instantiated by the exact same arguents.")
        
        guard matches.isNotEmpty else {
            throw InjectionError(cause: DependencyContainerError.missingDependency(typeName))
        }
        
        var instances = [T]()
        
        for dependency in matches {
            do {
                let instance = try dependency.instantiator.instantiate(parameters: parameters)
                let typedInstance = try cast(instance, as: T.self)
                
                instances.append(typedInstance)
                
                if let preInjectionNotifiedInstance = typedInstance as? PreInjectionNotified {
                    preInjectionNotifiedInstance.willInject()
                }
            } catch {
                throw InjectionError(cause: error)
            }
        }
        
        return instances
    }
    
    // MARK: Injection by Name
    
    /// Injects a dependency instance by name
    /// - Parameters:
    ///   - name: The name of the dependency
    ///   - type: The type the dependency is required to have
    /// - Returns: An instance of the dependency
    /// - Throws: An error if the dependency is not found or an instance was not successfully created.
    func inject<T>(named name: String, type: T.Type = T.self) throws -> T {
        return try inject(named: name, type: type, parameters: [])
    }
    
    /// Injects a dependency instance by name
    /// - Parameters:
    ///   - name: The name of the dependency
    ///   - type: The type the dependency is required to have
    ///   - parameters: The parameters required by the dependency initializer
    /// - Returns: An instance of the dependency
    /// - Throws: An error if the dependency is not found or an instance was not successfully created.
    func inject<T>(named name: String, type: T.Type = T.self, parameters: [Any]) throws -> T {
        let typeName = "\(type)"
        let matches = findDependencies(named: name)
        
        guard matches.isNotEmpty else {
            throw InjectionError(cause: DependencyContainerError.missingDependency(typeName))
        }
        
        guard let dependency = determineDependencyByPriority(in: matches) else {
            throw InjectionError(cause: DependencyContainerError.ambiguousDependency(typeName))
        }
        
        do {
            let instance = try dependency.instantiator.instantiate(parameters: parameters)
            let typedInstance = try cast(instance, as: T.self)
            
            if let preInjectionNotifiedInstance = typedInstance as? PreInjectionNotified {
                preInjectionNotifiedInstance.willInject()
            }
            
            return typedInstance
        } catch {
            throw InjectionError(cause: error)
        }
    }
    
    // MARK: Property Injection
    
    /// Injects a property dependency by name and type
    /// - Parameters:
    ///   - name: The name of the property
    ///   - type: The type of the property
    /// - Returns: The implementation of the property
    /// - Throws: An error if the property is not found.
    func injectProperty<T>(named name: String, type: T.Type = T.self) throws -> PropertyImplementation<T> {
        let typeName = "\(T.self)"
        let propertyName = "PropertyImplementation<\(typeName)>"
        let matches = findProperty(named: name, type: typeName)
        
        guard matches.isNotEmpty else {
            throw InjectionError(cause: DependencyContainerError.missingDependency(propertyName))
        }
        
        guard let dependency = determineDependencyByPriority(in: matches) else {
            throw InjectionError(cause: DependencyContainerError.ambiguousDependency(propertyName))
        }
        
        do {
            let instance = try dependency.instantiator.instantiate(parameters: [])
            return try cast(instance, as: PropertyImplementation<T>.self)
        } catch {
            throw InjectionError(cause: error)
        }
    }
    
    // MARK: Function Injection
    
    /// Injects a function dependency, with no parameters and Void result, by name and type.
    /// - Parameter name: The name of the function
    /// - Returns: The implementation of the function
    /// - Throws: An error if the function is not found.
    func injectFunction(named name: String) throws -> (()->()) {
        return try injectFunction(named: name, accepting: ["Void"], result: "Void")
    }
    
    /// Injects a function dependency, with no parameters and the given result, by name and type.
    /// - Parameter name: The name of the function
    /// - Returns: The implementation of the function
    /// - Throws: An error if the function is not found.
    func injectFunction<R>(named name: String) throws -> (()->R) {
        return try injectFunction(named: name, accepting: ["Void"], result: "\(R.self)")
    }
    
    /// Injects a function dependency, with the given parameter and the given result, by name and type.
    /// - Parameter name: The name of the function
    /// - Returns: The implementation of the function
    /// - Throws: An error if the function is not found.
    func injectFunction<P1,R>(named name: String) throws -> ((P1)->R) {
        return try injectFunction(named: name,
                                  accepting: [
                                    "\(P1.self)"
                                  ],
                                  result:"\(R.self)")
    }
    
    /// Injects a function dependency, with the given parameters and the given result, by name and type.
    /// - Parameter name: The name of the function
    /// - Returns: The implementation of the function
    /// - Throws: An error if the function is not found.
    func injectFunction<P1, P2, R>(named name: String) throws -> ((P1, P2)->R) {
        return try injectFunction(named: name,
                                  accepting: [
                                    "\(P1.self)",
                                    "\(P2.self)"
                                  ],
                                  result:"\(R.self)")
    }
    
    /// Injects a function dependency, with the given parameters and the given result, by name and type.
    /// - Parameter name: The name of the function
    /// - Returns: The implementation of the function
    /// - Throws: An error if the function is not found.
    func injectFunction<P1, P2, P3, R>(named name: String) throws -> ((P1, P2, P3)->R) {
        return try injectFunction(named: name,
                                  accepting: [
                                    "\(P1.self)",
                                    "\(P2.self)",
                                    "\(P3.self)"
                                  ],
                                  result:"\(R.self)")
    }
    
    /// Injects a function dependency, with the given parameters and the given result, by name and type.
    /// - Parameter name: The name of the function
    /// - Returns: The implementation of the function
    /// - Throws: An error if the function is not found.
    func injectFunction<P1, P2, P3, P4, R>(named name: String) throws -> ((P1, P2, P3, P4)->R) {
        return try injectFunction(named: name,
                                  accepting: [
                                    "\(P1.self)",
                                    "\(P2.self)",
                                    "\(P3.self)",
                                    "\(P4.self)"
                                  ],
                                  result:"\(R.self)")
    }
    
    /// Injects a function dependency, with the given parameters and the given result, by name and type.
    /// - Parameter name: The name of the function
    /// - Returns: The implementation of the function
    /// - Throws: An error if the function is not found.
    func injectFunction<P1, P2, P3, P4, P5, R>(named name: String) throws -> ((P1, P2, P3, P4, P5)->R) {
        return try injectFunction(named: name,
                                  accepting: [
                                    "\(P1.self)",
                                    "\(P2.self)",
                                    "\(P3.self)",
                                    "\(P4.self)",
                                    "\(P5.self)"
                                  ],
                                  result:"\(R.self)")
    }
    
    /// Injects a function dependency, with the given parameters and the given result, by name and type.
    /// - Parameter name: The name of the function
    /// - Returns: The implementation of the function
    /// - Throws: An error if the function is not found.
    func injectFunction<P1, P2, P3, P4, P5, P6, R>(named name: String) throws -> ((P1, P2, P3, P4, P5, P6)->R) {
        return try injectFunction(named: name,
                                  accepting: [
                                    "\(P1.self)",
                                    "\(P2.self)",
                                    "\(P3.self)",
                                    "\(P4.self)",
                                    "\(P5.self)",
                                    "\(P6.self)"
                                  ],
                                  result:"\(R.self)")
    }
    
    /// Injects a function dependency, with the given parameters and the given result, by name and type.
    /// - Parameter name: The name of the function
    /// - Returns: The implementation of the function
    /// - Throws: An error if the function is not found.
    func injectFunction<P1, P2, P3, P4, P5, P6, P7, R>(named name: String) throws -> ((P1, P2, P3, P4, P5, P6, P7)->R) {
        return try injectFunction(named: name,
                                  accepting: [
                                    "\(P1.self)",
                                    "\(P2.self)",
                                    "\(P3.self)",
                                    "\(P4.self)",
                                    "\(P5.self)",
                                    "\(P6.self)",
                                    "\(P7.self)"
                                  ],
                                  result:"\(R.self)")
    }
    
    /// Injects a function dependency, with the given parameters and result, by name and type.
    /// - Parameters:
    ///   - name: The name of the function
    ///   - parameters: An array of the type names the function uses as parameters
    ///   - result: The type name of the result the function returns
    /// - Returns: The implementation of the function
    /// - Throws: An error if the function is not found.
    func injectFunction<T>(named name: String, accepting parameters: [String], result: String) throws -> T {
        let functionTypeName = "\(name)(\(parameters.joined(separator: ",")))->\(result)"
        let matches = findFunction(named: name, parameters: parameters, result: result)
        
        guard matches.isNotEmpty else {
            throw InjectionError(cause: DependencyContainerError.missingDependency(functionTypeName))
        }
        
        guard let dependency = determineDependencyByPriority(in: matches) else {
            throw InjectionError(cause: DependencyContainerError.ambiguousDependency(functionTypeName))
        }
        
        do {
            let instance = try dependency.instantiator.instantiate(parameters: [])
            return try cast(instance, as: T.self)
        } catch {
            throw InjectionError(cause: error)
        }
    }
    
}

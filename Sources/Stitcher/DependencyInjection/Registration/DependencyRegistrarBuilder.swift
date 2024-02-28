//
//  DependencyRegistrarBuilder.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 12/2/24.
//

import Foundation

@resultBuilder
public struct DependencyRegistrarBuilder {
    public typealias Output = DependencyContainer.DependenciesRegistrar
    
    public static func buildBlock(
        _ components: Output...
    ) -> Output {
        
        return Output(
            components
                .reduce(Output()) { partialResult, current in
                    return partialResult.union(current)
                }
        )
    }
    
    public static func buildExpression<T, Trait: DependencyLocatorTrait>(
        _ expression: Dependency<T, Trait>
    ) -> Output {
        
        return Output([RawDependencyRegistration(expression)])
    }
    
    @available(
        *,
         deprecated,
         message: "Optional dependencies are not supported and may lead to undefined behaviour. Please consider wrapping the definition in a conditional statement instead."
    )
    public static func buildExpression<T, Trait: DependencyLocatorTrait>(
        _ expression: Dependency<Optional<T>, Trait>
    ) -> Output {
        
        return Output([RawDependencyRegistration(expression)])
    }
    
    
    public static func buildExpression(
        _ expression: DependencyGroup
    ) -> Output {
        
        return expression.dependencies()
    }
    
    
    public static func buildExpression<DependencyRepresentation: DependencyRepresenting>(
        _ expression: DependencyRepresentation
    ) -> Output {
        
        return Output([RawDependencyRegistration(expression)])
    }
    
    static func buildExpression<DependencyGroupRepresentation: DependencyGroupRepresenting>(
        _ expression: DependencyGroupRepresentation
    ) -> Output {
        
        return expression.dependencies()
    }
    
    @_disfavoredOverload
    public static func buildExpression<T>(
        _ expression: @escaping @Sendable @autoclosure () -> T
    ) -> Output {
        
        let dependency = Dependency(dependecy: expression)
        return Output([RawDependencyRegistration(dependency)])
    }
    
    
    public static func buildEither(
        first component: Output
    ) -> Output {
        
        return component
    }
    
    public static func buildEither(
        second component: Output
    ) -> Output {
        
        return component
    }
    
    public static func buildOptional(
        _ component: Output?
    ) -> Output {
        
        return component ?? []
    }
    
    public static func buildExpression(
        _ expression: Output
    ) -> Output {
        
        return expression
    }
}

//
//  DependencyRegistrarBuilder.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 12/2/24.
//

import Foundation

@resultBuilder
public struct DependencyRegistrarBuilder {
    public typealias Output = DependenciesRegistrar
    public typealias IntermediateResult = Array<RawDependencyRegistration>
    
    public static func buildBlock(
        _ components: IntermediateResult...
    ) -> IntermediateResult {

        return components
            .reduce(IntermediateResult()) { partialResult, current in
                var partialResult = partialResult
                partialResult.append(contentsOf: current)
                return partialResult
            }
    }
    
    public static func buildExpression<T, Trait: DependencyLocatorTrait>(
        _ expression: Dependency<T, Trait>
    ) -> IntermediateResult {
        
        return IntermediateResult([RawDependencyRegistration(expression)])
    }
    
    @available(
        *,
         deprecated,
         message: "Optional dependencies are not supported and may lead to undefined behaviour. Please consider wrapping the definition in a conditional statement instead."
    )
    public static func buildExpression<T, Trait: DependencyLocatorTrait>(
        _ expression: Dependency<Optional<T>, Trait>
    ) -> IntermediateResult {
        
        return IntermediateResult([RawDependencyRegistration(expression)])
    }
    
    
    public static func buildExpression(
        _ expression: DependencyGroup
    ) -> IntermediateResult {
        
        return expression
            .dependencies()
            .toArray()
    }
    
    
    public static func buildExpression<DependencyRepresentation: DependencyRepresenting>(
        _ expression: DependencyRepresentation
    ) -> IntermediateResult {
        
        return IntermediateResult([RawDependencyRegistration(expression)])
    }
    
    static func buildExpression<DependencyGroupRepresentation: DependencyGroupRepresenting>(
        _ expression: DependencyGroupRepresentation
    ) -> IntermediateResult {
        
        return expression
            .dependencies()
            .toArray()
    }
    
    @_disfavoredOverload
    public static func buildExpression<T>(
        _ expression: @escaping @Sendable @autoclosure () -> T
    ) -> IntermediateResult {
        
        let dependency = Dependency(dependecy: expression)
        return IntermediateResult([RawDependencyRegistration(dependency)])
    }
    
    
    public static func buildEither(
        first component: IntermediateResult
    ) -> IntermediateResult {
        
        return component
    }
    
    public static func buildEither(
        second component: IntermediateResult
    ) -> IntermediateResult {
        
        return component
    }
    
    public static func buildOptional(
        _ component: IntermediateResult?
    ) -> IntermediateResult {
        
        return component ?? []
    }
    
    public static func buildExpression(
        _ expression: IntermediateResult
    ) -> IntermediateResult {
        
        return expression
    }
    
    public static func buildFinalResult(_ component: IntermediateResult) -> Output {
        Output(component)
    }
}

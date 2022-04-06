//
//  SyntheticFunction.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 6/3/22.
//

import Foundation

/// A result builder that synthesizes and invokes a function from the active `DependencyGraph`.
@resultBuilder
public enum SyntheticFunction: UnsafeSyntheticMember {
    
    public static func buildBlock<P, R>(_ components: FunctionInvocation<P, R>) -> R {
        return components.invoke()
    }
    
    public static func buildBlock<P, R>(_ components: ThrowingFunctionInvocation<P, R>) throws -> R {
        return try components.invoke()
    }
    
    @available(iOS 13.0.0, macOS 10.15.0, tvOS 13.0.0, watchOS 6.0.0, *)
    public static func buildBlock<P, R>(_ components: AsyncFunctionInvocation<P, R>) async -> R {
        return await components.invoke()
    }
    
    @available(iOS 13.0.0, macOS 10.15.0, tvOS 13.0.0, watchOS 6.0.0, *)
    public static func buildBlock<P, R>(_ components: AsyncThrowingFunctionInvocation<P, R>) async throws -> R {
        return try await components.invoke()
    }
    
}

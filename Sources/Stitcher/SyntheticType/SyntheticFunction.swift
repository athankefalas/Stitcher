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
//  SyntheticFunction.swift
//  
//
//  Created by Athanasios Kefalas on 6/3/22.
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

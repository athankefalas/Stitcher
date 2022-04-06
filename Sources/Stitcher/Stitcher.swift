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
//  Stitcher.swift
//
//
//  Created by Athanasios Kefalas on 22/12/21.
//

import Foundation

/// A type that holds configuration options for the Stitcher library.
public final class Stitcher {
    
    /// A function that creates and returns an instance of DepedencyStorage
    public typealias StorageInstantiator = () -> DependencyStorage
    
    public struct Configuration {
        
#if DEBUG
        private static let shouldValidateDependencyGraph = true
#else
        private static let shouldValidateDependencyGraph = false
#endif
        
        /// A type that represents a configuration option
        enum Option: String, RawRepresentable, Hashable {
            case validateDependencyGraph
            case warnUnsafeSyntheticTypeUsage
        }
        
        /// The logger used by the Stitcher library to emit warning, error and informational messages
        public var logger: StitcherLogger = StitcherPrintLogger()
        /// A factory method that creates the dependency storage used by the dependency graph.
        /// This is client configurable and any compatible data structure is compatible as long as it conforms
        ///  to the `DependencyStorage` protocol.
        public var storageFactory: StorageInstantiator = { ArrayDependencyStorage() }
        
        var options: [Option : Bool] = [
            .warnUnsafeSyntheticTypeUsage : true,
            .validateDependencyGraph : shouldValidateDependencyGraph
        ]
        
        /// A switch that controls whether Stitcher will issue warnings when using the UnsafeSyntheticType feature.
        /// By default this is set to true.
        public var warnUnsafeSyntheticTypeUsage : Bool {
            get {
                return options[.warnUnsafeSyntheticTypeUsage, default: true]
            }
            
            set {
                options[.warnUnsafeSyntheticTypeUsage] = newValue
            }
        }
        
        /// A switch that controls whether Stitcher will validate a dependency container during it's activation.
        /// By default this options is true in DEBUG builds, to avoid long launch times in production.
        public var validateDependencyGraph: Bool {
            get {
                return options[.validateDependencyGraph, default: Self.shouldValidateDependencyGraph]
            }
            
            set {
                options[.validateDependencyGraph] = newValue
            }
        }
    }
    
    /// The active configuration used by the Stitcher library.
    public static var configuration = Configuration()

    private init() {}
}

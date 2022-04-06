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
//  ArrayDependencyStorage.swift
//  
//
//  Created by Athanasios Kefalas on 5/3/22.
//

import Foundation

/// A `DependencyStorage` that uses an array as the underlying storage.
public final class ArrayDependencyStorage: DependencyStorage {
    
    private var dependencies: [Dependency] = []
    
    public func append(_ dependency: Dependency) {
        dependencies.append(dependency)
    }
    
    public func remove(_ dependency: Dependency) {
        dependencies.removeAll(where: { $0 == dependency })
    }
    
    public func contains(_ dependency: Dependency) -> Bool {
        return dependencies.contains(dependency)
    }
    
    public func find(matching queries: [DependencyLocatorQuery]) -> [Dependency] {
        
        guard queries.isNotEmpty else {
            return []
        }
        
        var queries = queries
        var globalMatches = Set(findAll(matching: queries.removeFirst()))
        
        for query in queries {
            let matches = Set(findAll(matching: query))
            
            guard globalMatches.isNotEmpty else {
                globalMatches = matches
                continue
            }
            
            globalMatches = globalMatches.intersection(matches)
        }
        
        return Array(globalMatches)
    }
    
    private func findAll(matching query: DependencyLocatorQuery) -> [Dependency] {
        return dependencies
            .filter({ query.isSatisfied(by: $0.locator) })
    }
}

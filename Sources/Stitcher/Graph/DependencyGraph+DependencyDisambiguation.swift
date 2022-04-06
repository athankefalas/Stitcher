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
//  DependencyGraph+DependencyDisambiguation.swift
//  
//
//  Created by Athanasios Kefalas on 5/4/22.
//

import Foundation

extension DependencyGraph {
    
    func determineDependencyByPriority(in matches: [Dependency]) -> Dependency? {
        let sortedMatches = matches
            .map({ (priority: $0.priority, dependency: $0) })
            .sorted(by: { $0.priority > $1.priority })
        
        guard sortedMatches.count > 1 else {
            return sortedMatches.first?.dependency
        }
        
        if sortedMatches[0].priority == sortedMatches[1].priority {
            return nil
        } else {
            return sortedMatches.first?.dependency
        }
    }
}

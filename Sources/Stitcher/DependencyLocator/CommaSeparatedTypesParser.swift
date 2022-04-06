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
//  CommaSeparatedTypesParser.swift
//  
//
//  Created by Athanasios Kefalas on 16/1/22.
//

import Foundation

/// A helper that can parse an String of comma separated Swift types into an array of canonical Swift type names.
struct CommaSeparatedTypesParser {
    
    func parseTypes(from typesString: String) -> [String] {
        var separatorIndices: [String.Index] = []
        
        var currentParenthesisDepth = 0
        var currentGenericParameterDepth = 0
        
        for index in typesString.indices {
            let current = String(typesString[index])
            
            switch current {
            case ",":
                guard currentParenthesisDepth == 0,
                      currentGenericParameterDepth == 0 else {
                    continue
                }
                
                separatorIndices.append(index)
            case "(":
                currentParenthesisDepth += 1
            case ")":
                currentParenthesisDepth -= 1
            case "<":
                currentGenericParameterDepth += 1
            case ">":
                var isFunctionReturnOperator = false
                let previousIndex = typesString.index(before: index)
                
                if previousIndex >= typesString.startIndex,
                   typesString[previousIndex] == "-" {
                    isFunctionReturnOperator = true
                }
                
                if !isFunctionReturnOperator {
                    currentGenericParameterDepth -= 1
                }
            default:
                continue
            }
        }
        
        var parsedTypes: [String] = []
        var fromIndex = typesString.startIndex
        var toIndex = typesString.startIndex
        
        for separatorIndex in separatorIndices {
            fromIndex = toIndex == typesString.startIndex ? toIndex : typesString.index(after: toIndex)
            toIndex = separatorIndex
            
            let substring = typesString[fromIndex..<toIndex]
            parsedTypes.append(String(substring))
        }
        
        fromIndex = toIndex == typesString.startIndex ? toIndex : typesString.index(after: toIndex)
        toIndex = typesString.endIndex
        
        let substring = typesString[fromIndex..<toIndex]
        parsedTypes.append(String(substring))
        
        return parsedTypes
    }
    
}

//
//  CommaSeparatedTypesParser.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 16/1/22.
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

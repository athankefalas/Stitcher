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
//  DependencyLocatorQuery.swift
//  
//
//  Created by Athanasios Kefalas on 5/3/22.
//

import Foundation

/// A type that can be used to query a `DependencyStorage` for matching dependencies
public enum DependencyLocatorQuery {
    case find(DependencyLocator)
    case findByName(String)
    case findByType(String)
    case findByParameters([String])
    case findByResult(String)
    
    /// A predicate fuction that tests whether a `DependencyLocator` matches with this query
    /// - Parameter locator: The ocator to test
    /// - Returns: A boolean value, indicating whether the locator matches the query or not
    public func isSatisfied(by locator: DependencyLocator) -> Bool {
        switch self {
        case .find(let queryLocator):
            return queryLocator == locator
        case .findByName(let queryName):
            return name(queryName, matches: locator)
        case .findByType(let queryType):
            return type(queryType, matches: locator)
        case .findByParameters(let queryParameters):
            return parameters(queryParameters, matches: locator)
        case .findByResult(let queryResult):
            return result(queryResult, matches: locator)
        }
    }
    
    private func name(_ queryName: String, matches locator: DependencyLocator) -> Bool {
        switch locator {
        case .name(let dependencyName):
            return dependencyName == queryName
        case .type(_, _):
            return false
        case .property(let propertyName, _):
            return propertyName == queryName
        case .function(let functionName, _, _):
            return functionName == queryName
        }
    }
    
    private func type(_ queryType: String, matches locator: DependencyLocator) -> Bool {
        switch locator {
        case .name(_):
            return false
        case .type(let type, supertypes: let supertypes):
            return type == queryType || supertypes.contains(queryType)
        case .property(_, type: let type):
            return type == queryType
        case .function(_, parameters: _, result: _):
            return false
        }
    }
    
    private func parameters(_ queryParameters: [String], matches locator: DependencyLocator) -> Bool {
        switch locator {
        case .name(_):
            return false
        case .type(_, supertypes: _):
            return false
        case .property(_, type: _):
            return false
        case .function(_, parameters: let parameters, result: _):
            let normalizedQueryParameters = parameters
                .map { $0 == "()" ? "Void" : $0 }
            
            return Set(parameters) == Set(normalizedQueryParameters)
        }
    }
    
    private func result(_ queryResult: String, matches locator: DependencyLocator) -> Bool {
        switch locator {
        case .name(_):
            return false
        case .type(_, supertypes: _):
            return false
        case .property(_, type: _):
            return false
        case .function(_, parameters: _, result: let result):
            let normalizerQueryResult = queryResult == "()" ? "Void" : queryResult
            return Set([result]) == Set([normalizerQueryResult])
        }
    }
}

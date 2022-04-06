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
//  DependencyLocator.swift
//  
//
//  Created by Athanasios Kefalas on 16/1/22.
//

import Foundation

/// A locator that uniquely identifies a dependency and can be used to locate it.
public enum DependencyLocator: Equatable, Hashable, RawRepresentable {
    case name(String)
    case type(String, supertypes: [String] = [])
    case property(String, type: String)
    case function(String, parameters: [String], result: String)
    
    
    // MARK: Implementation
    
    public var rawValue: String {
        switch self {
        case .name(let name):
            return "urn:stitcher:dependency-locator:name?name=\(name)"
        case .type(let type, supertypes: let supertypes):
            let supertypes = supertypes.map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
            
            guard supertypes.isNotEmpty else {
                return "urn:stitcher:dependency-locator:type?type=\(type)"
            }
            
            let supertypesString = supertypes.joined(separator: ",")
            return "urn:stitcher:dependency-locator:type?type=\(type)&supertypes=\(supertypesString)"
        case .property(let name, let type):
            return "urn:stitcher:dependency-locator:property?name=\(name)&type=\(type)"
        case .function(let name, parameters: let parameters, result: let result):
            let parameters = parameters
                .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
                .joined(separator: ",")
            
            return "urn:stitcher:dependency-locator:func?name=\(name)&parameters=\(parameters.isEmpty ? "Void" : parameters)&result=\(result)"
        }
    }
    
    public init?(urn: URL) {
        self.init(rawValue: urn.absoluteString)
    }
    
    public init?(rawValue: String?) {
        guard let rawValue = rawValue else {
            return nil
        }
        
        self.init(rawValue: rawValue)
    }
    
    public init?(rawValue: String) {
        guard let urlComponents = URLComponents(string: rawValue) else {
            return nil
        }
        
        guard urlComponents.scheme == "urn" else {
            return nil
        }
        
        let typesParser = CommaSeparatedTypesParser()
        
        switch urlComponents.path {
        case "stitcher:dependency-locator:name":
            guard let nameItem = urlComponents.queryItems?.first(where: { $0.name == "name" }),
                  let nameValue = nameItem.value else {
                return nil
            }
            
            self = .name(nameValue)
        case "stitcher:dependency-locator:type":
            guard let typeItem = urlComponents.queryItems?.first(where: { $0.name == "type" }),
                  let typeValue = typeItem.value else {
                return nil
            }
            
            if let supertypesItem = urlComponents.queryItems?.first(where: { $0.name == "supertypes" }) {
                
                guard let supertypesValue = supertypesItem.value else {
                    return nil
                }
                
                let supertypes = typesParser.parseTypes(from: supertypesValue)
                self = .type(typeValue, supertypes: supertypes)
            } else {
                self = .type(typeValue, supertypes: [])
            }
        case "stitcher:dependency-locator:property":
            guard let nameItem = urlComponents.queryItems?.first(where: { $0.name == "name" }),
                  let nameValue = nameItem.value,
                  let typeItem = urlComponents.queryItems?.first(where: { $0.name == "type" }),
                  let typeValue = typeItem.value else {
                return nil
            }
            
            self = .property(nameValue, type: typeValue)
        case "stitcher:dependency-locator:func":
            guard let nameItem = urlComponents.queryItems?.first(where: { $0.name == "name" }),
                  let nameValue = nameItem.value,
                  let parametersItem = urlComponents.queryItems?.first(where: { $0.name == "parameters" }),
                  let parametersValue = parametersItem.value,
                  let resultItem = urlComponents.queryItems?.first(where: { $0.name == "result" }),
                  let resultValue = resultItem.value else {
                return nil
            }
            
            let parameters = typesParser.parseTypes(from: parametersValue)
            self = .function(nameValue, parameters: parameters, result: resultValue)
        default:
            return nil
        }
    }
    
    // MARK: Type Static Initializers
    
    public static func type<T>(_ type: T.Type) -> DependencyLocator {
        return .type("\(type)")
    }
    
    public static func type<T, S>(_ type: T.Type, supertype: S.Type = S.self) -> DependencyLocator {
        return .type("\(type)", supertypes: ["\(supertype)"])
    }
    
    public static func type<T, S1, S2>(_ type: T.Type, supertypes firstSupertype: S1.Type = S1.self, _ secondSupertype: S2.Type = S2.self) -> DependencyLocator {
        return .type("\(type)", supertypes: ["\(firstSupertype)", "\(secondSupertype)"])
    }
    
    public static func type<T, S1, S2, S3>(_ type: T.Type, supertypes firstSupertype: S1.Type = S1.self, _ secondSupertype: S2.Type = S2.self, _ thirdSupertype: S3.Type = S3.self) -> DependencyLocator {
        return .type("\(type)", supertypes: ["\(firstSupertype)", "\(secondSupertype)", "\(thirdSupertype)"])
    }
    
    // MARK: Property Static Initializers
    
    public static func property<T>(_ name: String, type: T.Type) -> DependencyLocator {
        return .property(name, type: "\(type)")
    }
    
    // MARK: Function Static Initializers
    
    public static func function(_ name: String) -> DependencyLocator {
        return .function(name, parameters: ["Void"], result: "Void")
    }
    
    public static func function<T>(_ name: String, accepting parameter: T.Type = T.self) -> DependencyLocator {
        return .function(name, parameters: ["\(parameter)"], result: "Void")
    }
    
    public static func function<R>(_ name: String, returning result: R.Type = R.self) -> DependencyLocator {
        return .function(name, parameters: ["Void"], result: "\(result)")
    }
    
    public static func function<T1, R>(_ name: String,
                                       accepting parameter: T1.Type = T1.self,
                                       returning result: R.Type = R.self) -> DependencyLocator {
        
        return .function(name, parameters: ["\(parameter)"], result: "\(result)")
    }
    
    public static func function<T1, T2, R>(_ name: String,
                                           accepting parameter1: T1.Type = T1.self,
                                           _ parameter2: T2.Type = T2.self,
                                           returning result: R.Type = R.self) -> DependencyLocator {
        
        let parameters = [
            "\(parameter1)",
            "\(parameter2)"
        ]
        
        return .function(name, parameters: parameters, result: "\(result)")
    }
    
    public static func function<T1, T2, T3, R>(_ name: String,
                                               accepting parameter1: T1.Type = T1.self,
                                               _ parameter2: T2.Type = T2.self,
                                               _ parameter3: T3.Type = T3.self,
                                               returning result: R.Type = R.self) -> DependencyLocator {
        
        let parameters = [
            "\(parameter1)",
            "\(parameter2)",
            "\(parameter3)"
        ]
        
        return .function(name, parameters: parameters, result: "\(result)")
    }
    
    public static func function<T1, T2, T3, T4, R>(_ name: String,
                                                   accepting parameter1: T1.Type = T1.self,
                                                   _ parameter2: T2.Type = T2.self,
                                                   _ parameter3: T3.Type = T3.self,
                                                   _ parameter4: T4.Type = T4.self,
                                                   returning result: R.Type = R.self) -> DependencyLocator {
        
        let parameters = [
            "\(parameter1)",
            "\(parameter2)",
            "\(parameter3)",
            "\(parameter4)"
        ]
        
        return .function(name, parameters: parameters, result: "\(result)")
    }
    
    public static func function<T1, T2, T3, T4, T5, R>(_ name: String,
                                                       accepting parameter1: T1.Type = T1.self,
                                                       _ parameter2: T2.Type = T2.self,
                                                       _ parameter3: T3.Type = T3.self,
                                                       _ parameter4: T4.Type = T4.self,
                                                       _ parameter5: T5.Type = T5.self,
                                                       returning result: R.Type = R.self) -> DependencyLocator {
        
        let parameters = [
            "\(parameter1)",
            "\(parameter2)",
            "\(parameter3)",
            "\(parameter4)",
            "\(parameter5)"
        ]
        
        return .function(name, parameters: parameters, result: "\(result)")
    }
    
    public static func function<T1, T2, T3, T4, T5, T6, R>(_ name: String,
                                                           accepting parameter1: T1.Type = T1.self,
                                                           _ parameter2: T2.Type = T2.self,
                                                           _ parameter3: T3.Type = T3.self,
                                                           _ parameter4: T4.Type = T4.self,
                                                           _ parameter5: T5.Type = T5.self,
                                                           _ parameter6: T6.Type = T6.self,
                                                           returning result: R.Type = R.self) -> DependencyLocator {
        
        let parameters = [
            "\(parameter1)",
            "\(parameter2)",
            "\(parameter3)",
            "\(parameter4)",
            "\(parameter5)",
            "\(parameter6)"
        ]
        
        return .function(name, parameters: parameters, result: "\(result)")
    }
    
    public static func function<T1, T2, T3, T4, T5, T6, T7, R>(_ name: String,
                                                               accepting parameter1: T1.Type = T1.self,
                                                               _ parameter2: T2.Type = T2.self,
                                                               _ parameter3: T3.Type = T3.self,
                                                               _ parameter4: T4.Type = T4.self,
                                                               _ parameter5: T5.Type = T5.self,
                                                               _ parameter6: T6.Type = T6.self,
                                                               _ parameter7: T7.Type = T7.self,
                                                               returning result: R.Type = R.self) -> DependencyLocator {
        
        let parameters = [
            "\(parameter1)",
            "\(parameter2)",
            "\(parameter3)",
            "\(parameter4)",
            "\(parameter5)",
            "\(parameter6)",
            "\(parameter7)"
        ]
        
        return .function(name, parameters: parameters, result: "\(result)")
    }
}

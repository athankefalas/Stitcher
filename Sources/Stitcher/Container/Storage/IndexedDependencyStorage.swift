//
//  File.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 5/3/22.
//

import Foundation

/// A `DependencyStorage` that uses an indexed Hashmap as the underlying storage.
/// - Note: This storage type is currently an experimental feature. It was added as a way to handle very large
/// numbers of dependencies by using a Hashmap as an indexing mechanism. Please do not use this storage until
///  it is removed as an experimental feature and is properly tested for performance.
public final class IndexedDependencyStorage: DependencyStorage, Experimental {
    
    private typealias IndexedStorage = Hashtable<String, Entry>
    
    private struct Features {
        typealias Key = String
        let keys: Set<Key>
        
        init(singleton feature: String) {
            self.keys = Set([feature])
        }
        
        init(_ features: [String]) {
            self.keys = Set(features)
        }
        
        init(locator: DependencyLocator) {
            switch locator {
            case .name(let name):
                self.keys = Set([name])
            case .type(let type, let supertypes):
                self.keys = Set([type] + supertypes)
            case .property(let name, type: let type):
                self.keys = Set([name, type])
            case .function(let name, let parameters, let result):
                self.keys = Set([name] + parameters + [result])
            }
        }
        
        init(query: DependencyLocatorQuery) {
            switch query {
            case .find(let dependencyLocator):
                self = .init(locator: dependencyLocator)
            case .findByName(let name):
                self.keys = Set([name])
            case .findByType(let type):
                self.keys = Set([type])
            case .findByParameters(let parameters):
                self.keys = Set(parameters)
            case .findByResult(let result):
                self.keys = Set([result])
            }
        }
    }
    
    private final class Entry: Equatable, Hashable {
        let dependency: Dependency
        
        init(_ dependency: Dependency) {
            self.dependency = dependency
        }
        
        static func == (lhs: IndexedDependencyStorage.Entry, rhs: IndexedDependencyStorage.Entry) -> Bool {
            return lhs.dependency == rhs.dependency
        }
        
        static func == (lhs: IndexedDependencyStorage.Entry, rhs: DependencyLocator) -> Bool {
            return lhs.dependency.locator == rhs
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(dependency)
        }
    }
    
    private let indexedStorage = IndexedStorage(capacity: 100)
    
    public func append(_ dependency: Dependency) {
        let features = Features(locator: dependency.locator)
        indexedStorage.add(Entry(dependency), for: features.keys)
    }
    
    public func remove(_ dependency: Dependency) {
        let features = Features(locator: dependency.locator)
        indexedStorage.remove(Entry(dependency), for: features.keys)
    }
    
    public func contains(_ dependency: Dependency) -> Bool {
        let features = Features(locator: dependency.locator)
        return indexedStorage.contains(Entry(dependency), at: features.keys)
    }
    
    public func find(matching queries: [DependencyLocatorQuery]) -> [Dependency] {
        
        guard queries.isNotEmpty else {
            return []
        }
        
        var queries = queries
        var globalMatches = findAll(matching: queries.removeFirst())
        
        for query in queries {
            let matches = findAll(matching: query)
            
            guard globalMatches.isNotEmpty else {
                globalMatches = Set(matches)
                continue
            }
            
            globalMatches = globalMatches.intersection(matches)
        }
        
        return globalMatches.map({ $0.dependency })
    }
    
    private func findAll(matching query: DependencyLocatorQuery) -> Set<Entry> {
        let features = Features(query: query)
        
        var matches = Set<Entry>()
        
        for key in features.keys {
            let dependencies = indexedStorage[key]
            
            guard matches.isNotEmpty else {
                matches = Set(dependencies)
                continue
            }
            
            matches = matches.intersection(dependencies)
        }
        
        return matches.filter({ query.isSatisfied(by: $0.dependency.locator) })
    }
    
}

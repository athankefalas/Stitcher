//
//  IndexingReducer.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 15/3/24.
//

import Foundation

public struct IndexingReducer {
    
    private let _appendDependency: (RawDependencyRegistration, IndexingKey) -> Void
    private let _didIndexDependency: (RawDependencyRegistration) -> Void
    
    init(
        appendDependency: @escaping (RawDependencyRegistration, IndexingKey) -> Void,
        didIndexDependency: @escaping (RawDependencyRegistration) -> Void
    ) {
        self._appendDependency = appendDependency
        self._didIndexDependency = didIndexDependency
    }
    
    public func append(dependency: RawDependencyRegistration, toKey key: IndexingKey) {
        _appendDependency(dependency, key)
    }
    
    public func didIndex(dependency: RawDependencyRegistration) {
        _didIndexDependency(dependency)
    }
}

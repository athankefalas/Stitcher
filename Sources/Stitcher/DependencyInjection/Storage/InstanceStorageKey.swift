//
//  InstanceStorageKey.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 13/2/24.
//

import Foundation

struct InstanceStorageKey: Hashable {
    let instanceType: TypeName
    let instanceLocator: DependencyLocator
    
    init(
        instanceType: TypeName,
        instanceLocator: DependencyLocator
    ) {
        self.instanceType = instanceType
        self.instanceLocator = instanceLocator
    }
}

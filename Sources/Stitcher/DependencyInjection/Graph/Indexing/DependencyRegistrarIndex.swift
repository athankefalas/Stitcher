//
//  DependencyRegistrarIndex.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 15/3/24.
//

import Foundation
import OrderedCollections

public typealias DependencyRegistrarIndex = Dictionary<IndexingKey, OrderedSet<RawDependencyRegistration>>

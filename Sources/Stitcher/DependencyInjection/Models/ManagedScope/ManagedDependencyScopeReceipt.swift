//
//  ManagedDependencyScopeReceipt.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 12/3/24.
//

import Foundation
import OpenCombine

/// A receipt for a managed scope invalidation observation.
public protocol ManagedDependencyScopeReceipt {
    
    /// Cancels the registered observer immediately.
    func cancel()
}

extension AnyPipelineCancellable: ManagedDependencyScopeReceipt {}
extension OpenCombine.AnyCancellable: ManagedDependencyScopeReceipt {}

#if canImport(Combine)
import Combine

@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
extension Combine.AnyCancellable: ManagedDependencyScopeReceipt {}

#endif

//
//  ManagedDependencyScopeProviding.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 12/3/24.
//

import Foundation

/// A type that defines a manually managed dependency scope
public protocol ManagedDependencyScopeProviding: AnyObject {
    
    /// Registers the given action as a callback to be invoked when the managed scope is invalidated.
    /// - Parameter action: The callback to ivoke on scope invalidation events.
    /// - Returns: A receipt used to cancel the registered observation when it is no longer needed.
    func onScopeInvalidated(perform action: @Sendable @escaping () -> Void) -> ManagedDependencyScopeReceipt
}

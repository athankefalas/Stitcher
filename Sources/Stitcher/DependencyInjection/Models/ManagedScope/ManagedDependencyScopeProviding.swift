//
//  ManagedDependencyScopeProviding.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 12/3/24.
//

import Foundation

public protocol ManagedDependencyScopeProviding: AnyObject {
    
    func onScopeInvalidated(perform action: @Sendable @escaping () -> Void) -> ManagedDependencyScopeReceipt
}

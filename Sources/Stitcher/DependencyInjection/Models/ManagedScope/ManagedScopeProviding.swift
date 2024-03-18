//
//  ManagedScopeProviding.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 12/3/24.
//

import Foundation

public protocol ManagedScopeProviding: AnyObject {
    
    func onScopeInvalidated(perform action: @Sendable @escaping () -> Void) -> ManagedScopeReceipt
}

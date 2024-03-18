//
//  ManagedScopeReceipt.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 12/3/24.
//

import Foundation

public protocol ManagedScopeReceipt {
    
    func cancel()
}

extension AnyPipelineCancellable: ManagedScopeReceipt {}

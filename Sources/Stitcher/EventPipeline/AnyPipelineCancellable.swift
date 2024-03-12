//
//  AnyPipelineCancellable.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 12/3/24.
//

import Foundation
import OpenCombine

#if canImport(Combine)
import Combine
#endif

final class AnyPipelineCancellable: Hashable {
    
    private final class NoneProvider {
        let id = UUID()
    }
    
    private let providerHashcode: AnyHashable
    private let providerCancellable: AnyObject
    private let _cancel: () -> Void
    
    init() {
        let noneProvider = NoneProvider()
        providerHashcode = noneProvider.id
        providerCancellable = noneProvider
        _cancel = {}
    }
    
    #if canImport(Combine)
    
    @available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    init(_ cancellable: Combine.AnyCancellable) {
        self.providerHashcode = cancellable.hashValue
        self.providerCancellable = cancellable
        self._cancel = { cancellable.cancel() }
    }
    
    #endif
    
    init(_ cancellable: OpenCombine.AnyCancellable) {
        self.providerHashcode = cancellable.hashValue
        self.providerCancellable = cancellable
        self._cancel = { cancellable.cancel() }
    }
    
    deinit {
        cancel()
    }
    
    func cancel() {
        _cancel()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(providerHashcode)
    }
    
    func store<Storage: RangeReplaceableCollection>(
        in collection: inout Storage
    ) where Storage.Element == AnyPipelineCancellable {
        collection.append(self)
    }
    
    func store(
        in set: inout Set<AnyPipelineCancellable>
    ) {
        set.insert(self)
    }
    
    static func == (lhs: AnyPipelineCancellable, rhs: AnyPipelineCancellable) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

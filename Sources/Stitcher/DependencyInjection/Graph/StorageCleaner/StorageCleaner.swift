//
//  StorageCleaner.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 3/3/24.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

class StorageCleaner {
    
#if DEBUG
    @Atomic
    static var cleaupRequestsCount = 0
#endif
    
    private static let didInstantiateDependencySubject = PassthroughSubject<Void, Never>()
    
    private var cleanupHandler: @Sendable () async -> Void
    private var subscriptions = Set<AnyCancellable>()
    
    init(cleanupHandler: @Sendable @escaping () async -> Void) {
        self.cleanupHandler = cleanupHandler
        
        postInit()
    }
    
    deinit {
        subscriptions.forEach({ $0.cancel() })
        subscriptions.removeAll()
    }
    
    private func postInit() {
#if canImport(UIKit)
        NotificationCenter.default
            .publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.cleanupStorage(priority: .userInitiated)
            }
            .store(in: &subscriptions)
        
        NotificationCenter.default
            .publisher(for: UIApplication.didReceiveMemoryWarningNotification)
            .sink { [weak self] _ in
                self?.cleanupStorage(priority: .medium)
            }
            .store(in: &subscriptions)
#endif
        
#if canImport(AppKit)
        NotificationCenter.default
            .publisher(for: NSApplication.didResignActiveNotification)
            .sink { [weak self] _ in
                self?.cleanupStorage(priority: .userInitiated)
            }
            .store(in: &subscriptions)
#endif
        
        let autoCleanupFrequency = StitcherConfiguration.autoCleanupFrequency
        
        guard autoCleanupFrequency != .never else {
            return
        }
        
        Self.didInstantiateDependencySubject
            .debounce(for: 0.01, scheduler: DispatchQueue.global(qos: .utility))
            .collect(autoCleanupFrequency.rawValue)
            .sink { [weak self] _ in
                self?.cleanupStorage(priority: .low)
            }
            .store(in: &subscriptions)
    }
    
    private func cleanupStorage(priority: TaskPriority = .low) {
#if DEBUG
        Self.cleaupRequestsCount += 1
#endif
        
        Task(priority: priority) {
            await cleanupHandler()
        }
    }
    
    func didInstantiateDependency() {
        Self.didInstantiateDependencySubject.send()
    }
    
#if DEBUG
    static func didInstantiateDependency() {
        Self.didInstantiateDependencySubject.send()
    }
#endif
    
}

//
//  StorageCleaner.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 3/3/24.
//

import Foundation

#if canImport(UIKit) && canImport(Combine)
import UIKit
import Combine
#endif

#if canImport(AppKit) && canImport(Combine)
import AppKit
import Combine
#endif

class StorageCleaner {
    
    private var cleanupHandler: @Sendable () -> Void
    private var subscriptions = Set<AnyPipelineCancellable>()
    
    init(cleanupHandler: @Sendable @escaping () -> Void) {
        self.cleanupHandler = cleanupHandler
        
        postInit()
    }
    
    deinit {
        subscriptions.forEach({ $0.cancel() })
        subscriptions.removeAll()
    }
    
    private func postInit() {
#if canImport(UIKit) && canImport(Combine)
        if #available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *) {
            NotificationCenter.default
                .publisher(for: UIApplication.willResignActiveNotification)
                .sink { [weak self] _ in
                    self?.cleanupStorage(priority: .high)
                }
                .store(in: &subscriptions)
            
            NotificationCenter.default
                .publisher(for: UIApplication.didReceiveMemoryWarningNotification)
                .sink { [weak self] _ in
                    self?.cleanupStorage(priority: .medium)
                }
                .store(in: &subscriptions)
        }
#endif
        
#if canImport(AppKit) && canImport(Combine)
        if #available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *) {
            NotificationCenter.default
                .publisher(for: NSApplication.didResignActiveNotification)
                .sink { [weak self] _ in
                    self?.cleanupStorage(priority: .high)
                }
                .store(in: &subscriptions)
        }
#endif
    }
    
    private func cleanupStorage(priority: AsyncTask.Priority = .low) {
        
        guard StitcherConfiguration.autoCleanupEnabled else {
            return
        }
        
        AsyncTask(priority: priority) {
            self.cleanupHandler()
        }
    }
}

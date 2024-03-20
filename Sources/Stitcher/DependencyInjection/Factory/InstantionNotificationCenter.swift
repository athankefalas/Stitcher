//
//  InstantionNotificationCenter.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 19/3/24.
//

import Foundation

final class InstantionNotificationCenter {
        
    @Atomic
    private var pendingNotifications: [AnyPostInstantiationAware] = []
    
    private let pendingNotificationAddedSubject = PipelineSubject<Void>()
    private var subscriptions: Set<AnyPipelineCancellable> = []
    
    init() {
        pendingNotificationAddedSubject
            .debounce(
                for: 0.01,
                schedulerQos: .default
            )
            .sink { [weak self] in
                self?.sendPendingNotifications()
            }
            .store(in: &subscriptions)
    }
    
    deinit {
        subscriptions.forEach({ $0.cancel() })
        subscriptions.removeAll()
        pendingNotifications.removeAll()
    }
    
    private final func sendPendingNotifications() {
        let pendingNotifications = pendingNotifications
        self.pendingNotifications.removeAll()
        
        guard pendingNotifications.count > 0 else {
            return
        }
        
        AsyncTask(priority: .medium) {
            for notification in pendingNotifications {
                notification.didInstantiate()
            }
        }
    }
    
    @inlinable
    final func enqueueNotification<Instance: PostInstantiationAware>(to instance: Instance) {
        pendingNotifications.append(AnyPostInstantiationAware(instance))
        pendingNotificationAddedSubject.send()
    }
}

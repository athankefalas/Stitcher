//
//  DependencyCycleDetector.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 15/2/24.
//

import Foundation
import Combine

class DependencyCycleDetector {
    
    private let timestamp = Date()
    private let dependencyRegistration: RawDependencyRegistration
    private var subscription: AnyCancellable?
    
    init(on registration: RawDependencyRegistration) {
        self.dependencyRegistration = registration
        
        postInit()
    }
    
    deinit {
        subscription?.cancel()
        subscription = nil
    }
    
    private func postInit() {
        subscription = Just(timestamp)
            .delay(
                for: 0.1,
                scheduler: DispatchQueue.global(qos: .utility)
            )
            .sink { [weak self] _ in
                self?.possibleDependencyCycleDetected()
            }
    }
    
    private func possibleDependencyCycleDetected() {
        let error = InjectionError.cyclicDependencyReference(
            dependencyRegistration.locator.dependencyContext()
        )
        
        let type = dependencyRegistration.factory.type.canonicalValue
        fatalError("Possible dependency cycle detected while attempting to instantiate dependency with type '\(type)'. Error: \(error).")
    }
    
    func withCycleDetection<T>(perform block: () throws -> T) rethrows -> T {
        let result = try block()
        subscription?.cancel()
        subscription = nil
        
        return result
    }
}

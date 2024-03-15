//
//  ThreadLocal.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 12/3/24.
//

import Foundation

struct ThreadIdentifier: Hashable, CustomStringConvertible {
    
    private let identifier: Int
    
    var description: String {
        "ThreadIdentifier-\(identifier)"
    }
    
    private init() {
        self.identifier = ThreadValues.threadIdentifier
    }
    
    static var current: ThreadIdentifier {
        ThreadIdentifier()
    }
}

class ThreadStorage<Value>: CustomStringConvertible {
    
    @Atomic
    private var entries: [ThreadIdentifier : Value] = [:]
    
    var description: String {
        entries.description
    }
    
    init() {}
    
    func get() -> Value? {
        return entries[ThreadIdentifier.current]
    }
    
    func set(_ value: Value) {
        entries[ThreadIdentifier.current] = value
    }
}

@propertyWrapper
final class ThreadLocal<Value> {
    
    final let defaultValue: Value
    
    private var storage = ThreadStorage<Value>()
    
    final var wrappedValue: Value {
        storage.get() ?? defaultValue
    }
    
    final var projectedValue: ThreadLocal<Value> {
        self
    }
    
    init(
        wrappedValue defaultValue: Value
    ) {
        self.defaultValue = defaultValue
    }

    /// Gets the value currently bound to this task-local from the current task.
    ///
    /// If no current task is available in the context where this call is made,
    /// or if the task-local has no value bound, this will return the `defaultValue`
    /// of the task local.
    final func get() -> Value {
        wrappedValue
    }

    /// Binds the task-local to the specific value for the duration of the
    /// synchronous operation.
    ///
    /// The value is available throughout the execution of the operation closure,
    /// including any `get` operations performed by child-tasks created during the
    /// execution of the operation closure.
    ///
    /// If the same task-local is bound multiple times, be it in the same task, or
    /// in specific child tasks, the "more specific" binding is returned when the
    /// value is read.
    ///
    /// If the value is a reference type, it will be retained for the duration of
    /// the operation closure.
    @discardableResult
    final func withValue<R>(
        _ valueDuringOperation: Value,
        operation: () throws -> R,
        file: String = #fileID,
        line: UInt = #line
    ) rethrows -> R {
        let currentValue = get()
        storage.set(valueDuringOperation)
        
        defer {
            storage.set(currentValue)
        }
        
        return try operation()
    }
}

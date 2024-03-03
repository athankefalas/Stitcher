//
//  StitcherConfiguration.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 2/3/24.
//

import Foundation

/// A type that holds any configuration parameters for controlling the behaviour of sticher
public enum StitcherConfiguration {
    
    /// A type representing the frequency of automatic storage cleanup.
    public struct AutoCleanupFrequency: RawRepresentable, ExpressibleByIntegerLiteral {
        
        /// An approximate count of discreet dependency injection requests, normalized to once per 0.01 seconds.
        public let rawValue: Int
        
        private init() {
            self.rawValue = -1
        }
        
        public init(rawValue: Int) {
            self.rawValue = rawValue >= 0 ? rawValue : -1
        }
        
        public init(integerLiteral value: Int) {
            self.init(rawValue: value)
        }
        
        /// The storage will never be automatically cleaned.
        public static let never = AutoCleanupFrequency()
        
        /// The storage will be automatically cleaned **once** per 10 normalized injection requests.
        public static let veryLow = AutoCleanupFrequency(rawValue: 10)
        
        /// The storage will be automatically cleaned **once** per 6 normalized injection requests.
        public static let low = AutoCleanupFrequency(rawValue: 6)
        
        /// The storage will be automatically cleaned **once** per 4 normalized injection requests.
        public static let medium = AutoCleanupFrequency(rawValue: 4)
        
        /// The storage will be automatically cleaned **once** per 2 normalized injection requests.
        public static let high = AutoCleanupFrequency(rawValue: 2)
        
        /// The storage will be automatically cleaned **once** per normalized injection request.
        public static let veryHigh = AutoCleanupFrequency(rawValue: 1)
    }
    
    struct Snapshot {
        let isIndexingEnabled: Bool
        let approximateDependencyCount: Int
        let autoCleanupFrequency: AutoCleanupFrequency
        
        init() {
            self.isIndexingEnabled = StitcherConfiguration.isIndexingEnabled
            self.approximateDependencyCount = max(StitcherConfiguration.approximateDependencyCount, 100)
            self.autoCleanupFrequency = StitcherConfiguration.autoCleanupFrequency
        }
    }
    
    /// Controls whether indexing dependencies is enabled.
    ///
    /// When indexing is **disabled**, container initialization will be significantly faster,
    /// at the expense of dependency search operations during injection. Below is
    /// a table with the different time complexity values per operation based on whether
    /// indexing is enabled:
    /// 
    /// | Operation | Complexity with Indexing enabled | Complexity with Indexing disabled |
    /// | - | - | - |
    /// | Container Initialization | O(n^2)  | O(n) |
    /// | Dependency Search    | O(1) \*    | O(n) |
    ///
    /// \* On average based on the way the dependency is located. For example adding type
    /// aliases such as protocol conformances can increase lookup times for the specific protocol.
    /// However, it is highly unlikely that a dependency will be registred with more than 2 type aliases
    /// we can average the lookup time to O(1).
    @Atomic public static var isIndexingEnabled = true
    
    /// An approximate count of the dependencies defined in the app.
    ///
    /// This value is used for optimizing any heavy operations that use
    /// collections, such as indexing, by reserving the capacity of the
    /// collection beforehand thereby reducing the footprint of any memory
    /// expansion operations performed by the underlying storage of the collection.
    /// The default value is based on an assumption that an average executable can
    /// have approximately **10,000** dependencies at runtime. So at *worst*, the approximate
    /// dependency count can be approximately three times that, so around **30,000**.
    ///
    /// A good value for this field can be calculated easily by counting the dependencies
    /// defined in all containers in the following way:
    ///
    /// ```
    /// Count = NameDependencyCount + TypeDependencyCount + ValueDependencyCount
    ///
    /// Where:
    /// NameDependencyCount = Dependencies registered by name
    /// TypeDependencyCount = Dependencies registered by type * typealiases such as confromances and superclasses
    /// ValueDependencyCount = Dependencies registered by value
    ///
    /// For example:
    ///
    /// Dependency { SomeService() }.named("name")
    /// is counted as 1 dependency.
    ///
    /// Dependency { SomeService() }
    /// is counted as 1 dependency.
    ///
    /// Dependency { SomeService() }.inherits(from: SomeSuperclass.self)
    /// is counted as 2 dependencies.
    ///
    /// Dependency { SomeService() }.inherits(from: SomeSuperclass.self).conforms(to: SomeProtocol.self)
    /// is counted as 3 dependencies.
    ///
    /// Dependency { SomeService() }.associated(with: "name")
    /// is counted as 1 dependency.
    ///
    /// ```
    ///
    /// - Warning: Avoid changing this value unecessarily as it can negatively impact runtime memory footprint and performance.
    ///   Setting an arbitrarily high value may allocate a large portion of memory, while a low value can increase indexing time.
    @Atomic public static var approximateDependencyCount = 30_000
    
    /// Controls the frequency at which the dependency graph instance storage will be automatically cleaned up.
    @Atomic public static var autoCleanupFrequency = AutoCleanupFrequency.veryLow
}

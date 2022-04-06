import Foundation

/// A type that holds configuration options for the Stitcher library.
public final class Stitcher {
    
    /// A function that creates and returns an instance of DepedencyStorage
    public typealias StorageInstantiator = () -> DependencyStorage
    
    public struct Configuration {
        
#if DEBUG
        private static let shouldValidateDependencyGraph = true
#else
        private static let shouldValidateDependencyGraph = false
#endif
        
        /// A type that represents a configuration option
        enum Option: String, RawRepresentable, Hashable {
            case validateDependencyGraph
            case warnUnsafeSyntheticTypeUsage
        }
        
        /// The logger used by the Stitcher library to emit warning, error and informational messages
        public var logger: StitcherLogger = StitcherPrintLogger()
        /// A factory method that creates the dependency storage used by the dependency graph.
        /// This is client configurable and any compatible data structure is compatible as long as it conforms
        ///  to the `DependencyStorage` protocol.
        public var storageFactory: StorageInstantiator = { ArrayDependencyStorage() }
        
        var options: [Option : Bool] = [
            .warnUnsafeSyntheticTypeUsage : true,
            .validateDependencyGraph : shouldValidateDependencyGraph
        ]
        
        /// A switch that controls whether Stitcher will issue warnings when using the UnsafeSyntheticType feature.
        /// By default this is set to true.
        public var warnUnsafeSyntheticTypeUsage : Bool {
            get {
                return options[.warnUnsafeSyntheticTypeUsage, default: true]
            }
            
            set {
                options[.warnUnsafeSyntheticTypeUsage] = newValue
            }
        }
        
        /// A switch that controls whether Stitcher will validate a dependency container during it's activation.
        /// By default this options is true in DEBUG builds, to avoid long launch times in production.
        public var validateDependencyGraph: Bool {
            get {
                return options[.validateDependencyGraph, default: Self.shouldValidateDependencyGraph]
            }
            
            set {
                options[.validateDependencyGraph] = newValue
            }
        }
    }
    
    /// The active configuration used by the Stitcher library.
    public static var configuration = Configuration()

    private init() {}
}

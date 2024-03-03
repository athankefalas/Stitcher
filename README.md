# Stitcher

Stitcher is a dependecy injection library for Swift projects.

## ⏱ Version History

| Version | Changes                           |
|---------|-----------------------------------|
| 0.9.1   | Pre-release.                      |
| 1.0.0   | Initial release.                  |

## 🧰 Features

- Easy to setup.
- Declarative API for registering dependencies, including conditional dependecny definition.
- Scalable infrastructure using composition for modular projects.
- Supports for injection by name, by type and by associated values.
- Type safe initialization parameters for dependency initialization.
- Support for indexing dependencies in order to minimize injection time.

## 📦 Installation

### Swift Package

You may add Stitcher as a Swift Package dependency using Xcode 11.0 or later, by selecting `File > Swift Packages > Add Package Dependency...` or `File > Add packages...` in Xcode 13.0 and later, and adding the url below:

`https://github.com/athankefalas/Stitcher.git`

### Manually 

You may also install this library manually by downloading the `Stitcher` project and including it in your project.

## ⚡️ Quick Start

Define dependencies in your App struct or your UIApplication delegate, by using the `@Depenendecies` property wrapper:

``` swift

    @Dependencies
    private var container = DependencyContainer {
        // Dependency with no parameters
        AuthenticationService()
        
        // Dependency with parameters
        Dependency { location in
            ImageUploadService(targeting: location)
        }
        .scope(.instance)
    }

```

Inject a dependency using the `@Injected` property wrapper:

``` swift

class LoginSceneViewModel: ObservableObject {
    
    @Injected
    private var authenticationService: AuthenticationService
    
    func login(email: Email, password: Password) async {
        await authenticationService.attemptLogin(email: email, password: Password)
    }
}

class ProfileSceneViewModel: ObservableObject {
    
    @Injected(ImageUploadLocation.profileAvatar)
    private var avatarUploadService: ImageUploadService
    
    func upload(image: UIImage) async {
        await avatarUploadService.upload(image)
    } 
}

```



## 📋 Library Overview

The components defined and used by the library are the following:
1. **DependencyLocator**
An identifier used to uniquely locate a specific dependency.
2. **Dependency**
A way to define a dependency and a way to obtain an instance of it.
3. **Requirement** 
A way to define a dependency that is required to be defined in the app's DependencyGraph. Serves as a way to validate a dependency container.
4. **DependencyContainer**
A data structure that contains a set of dependencies and requirements, and that can be created by providing the dependencies it exports and any requirements, or by composing or merging several other containers.
5. **DependencyGraph**
The dependency graph is a globally accessible set of dependencies that are retrieved by activating a specific dependency container.

### Dependency Locator

A dependency locator is an identifier that can be used to uniquely identify a specific dependency. The `DependencyLocator` type is defined as a Swift `enum` that is represented by a String as it's rawValue. The raw value of a dependency locator is defined as a URN, meaning that it can be sythesized externally (by a server etc) and used in the app to dynamically load the appropriate dependency. However, it should be noted that defining a dependency locator at compile time, where applicable, is the more appropriate use in order to fully utilize the automatic injection features of the library.

The `DependencyLocator` enum has the following cases:
* `name` - *Used to identify any dependency by it's name.*
* `type` - *Used to identify any dependency by it's type.*
* `property` - *Used to identify a property dependency by it's name __and__ it's type.*
* `function` - *Used to identify a function dependency by it's name __and__ it's signature.*

The fact that a dependency is identified by it's locator means that a specific dependency can be defined multiple times using different distinct locators.

### Dependency

A dependency is an artifact that is declared as being available to use and be injected in any appropriate places. A dependency can be thought of something like a tuple. The first part of a dependency is a `DependencyLocator` which serves to identify the dependency, while the second part is an instance that conforms to the `DependencyInstantiating` protocol and serves to provide a function that creates (or retrieves) instances of the dependency. These two values are often hidden behind more simplified initializers which improve the syntax of defining a dependency. Some of these initializers will be discussed in the following sections. Finally, a dependency may also define a priority, which is a value between [0...1000] inclusive, and dictates the priority with which a dependency will be selected for injection.

#### Dependencies By Name

A dependency can be defined by it's name, by using the initializer `Dependency.init<T>(_: String, _: @escaping () -> T)` and it's variants. 

For example:

```swift

// Given the following classes

final class SomeDependency {
    init(){}
}

final class OtherDependencyStaging: OtherDependency {
    override init(parameter: String) {}
}

final class OtherDependencyProduction: OtherDependency {
    override init(parameter: String) {}
}

// We can export dependencies, like:

DependencyContainer("Tutorial") {
    Dependency("DependencyName", SomeDependency.init)
    
    if someEnvironmentVariable == .staging {
        Dependency("OtherDependencyName", OtherDependencyStaging.init)
    } else {
        Dependency("OtherDependencyName", OtherDependencyProduction.init)
    }
}
```
[1] The classes defined above need not be final.
[2] Types can be created with predefined `Dependency` initializers, having a parameters count in the range of [0,7] inclusive.

#### Dependencies By Type

A dependency can be defined by it's type, by using the initializer `Dependency.init<T>(_: @escaping () -> T)` and it's variants. 

For example:

```swift

// Given the following classes

final class SomeDependency {
    init(){}
}

final class SomeOtherDependency: Instantiable {
    required init(){}
}

protocol SomeProtocol {}

open class SomeImplementor: SomeProtocol {
    init(){}
}

final class SomeSubImplementor: SomeImplementor {
    init(){}
}

final class SomeThirdDependency {
    init(){}
}

// We can export dependencies, like:

DependencyContainer("Tutorial") {
    Dependency(SomeDependency.init)
    Dependency(SomeOtherDependency.self)
    
    // Define dependency by type and supertype
    Dependency(implementing: SomeProtocol.self, SomeImplementor.init) 
    
    // Define dependency by complex type hierarchy
    Dependency( 
        .type(
            SomeSubImplementor.self,
            supertypes: SomeImplementor.self, SomeProtocol.self
        ),
        SomeSubImplementor.init
    )
    
    if someCondition == true {
        Dependency(SomeThirdDependency.init)
    }
}
```
[1] The classes defined above need not be final.
[2] Types can be created with predefined `Dependency` initializers, having a parameters count in the range of [0,7] inclusive.
[3] Types that conform to the `Instantiable` protocol can be defined directly by their type.
[4] Dependencies defined by type hierarchies can match any their type as well as their supertypes when injecting them.

#### Property Dependencies

A dependency can also be defined as a property, by using the initializer `init<T>(property propertyName: String, get getter: @escaping () -> T, set setter: @escaping (T) -> Void)` and it's variants. 

For example:

```swift
DependencyContainer("Tutorial") {
    Dependency(property: "didShowOnboarding") {
        UserDefaults.standard.bool(forKey: "com.organization.app.launch.didShowOnboarding")
    } set: { newValue in
        UserDefaults.standard.set(newValue, forKey: "com.organization.app.launch.didShowOnboarding")
    }
}
```
[1] Property dependencies can also be defined by passing an instance of `PropertyImplementation<T>` or `Binding<T>`.

#### Function Dependencies

A dependency can also be defined as a function, by using the initializer `init<T>(property propertyName: String, get getter: @escaping () -> T, set setter: @escaping (T) -> Void)` and it's variants. 

For example:

```swift
fileprivate func someFunction(_ input: String) -> String {
    return input.lowercased()
}

fileprivate func someOtherFunction() -> Bool {
    return .random()
}

DependencyContainer("Tutorial") {
    Dependency(function: "SomeFunction", someFunction)
    
    Dependency { // Define function dependency by type
        someOtherFunction
    }
}
```
[1] Function dependencies can also be defined by type instead of as functions, and in the event that they are defined by type they behave as plain dependencies having a locator of `.type(FunctionSignature)` where FunctionSignature is the swift type of the function.
[2] Using the predefined `Dependency` initializers functions with up to 7 inputs ca be defined.

### Requirement
A way to define a dependency that is required to be defined in the app's `DependencyGraph`. Serves as a way to validate a dependency container. To define a requirement it is required to pass a `DependencyLocator` which will serve as the identity of the dependency to look for during the validation of the dependency container. Furthermore, as requirements are validated during the activation of the container, they may define required dependencies that are not local to their owning container.

By default, a dependency container will be validated when being activated by the `DependencyGraph` and **only** when the executable uses the `DEBUG` compilation flag. This behaviour is because of the fact that performing the validation may have significant overhead during the activation of a dependency container which may lead to increased launch times. 

Requirement definition example:
```swift
DependencyContainer("Tutorial") {
    // Define a dependency
    Dependency(property: "didShowOnboarding") {
        UserDefaults.standard.bool(forKey: "com.organization.app.launch.didShowOnboarding")
    } set: { newValue in
        UserDefaults.standard.set(newValue, forKey: "com.organization.app.launch.didShowOnboarding")
    }
} requires: {
    // Define a local requirement
    Requirement(.property("didShowOnboarding", type: Bool.self))
    
    // Define a requirement which may, or not, be fulfilled by another container
    Requirement(.name("MyRequiredDependency"))
}
```

### DependencyContainer
A data structure that contains a set of dependencies and requirements, and that can be created by providing the dependencies it exports and any requirements, or by composing or merging several other containers.

A container can either be built using the declarative builders shown in previous examples, by passing arrays of dependencies and requirements and by merging 2 or more separate containers. Furthermore, a static factory method is available as a way to declaratively compose multiple containers.

Requirement definition example:
```swift
// Given the following classes

final class SomeDependency {
    init(){}
}

final class SomeOtherDependency {
    init(){}
}

// Declaratively create a composited container, merging 2 others.
// Note: The resulting DependencyContainer will have 2 dependencies and 2 requirements.
try DependencyContainer.compose(name: "Tutorial") {

    DependencyContainer("Tutorial-Fragment-1") {
        Dependency("SomeDependency", SomeDependency.init)
    } requires: {
        Requirement(.name("SomeOtherDependency"))
    }
    
    DependencyContainer("Tutorial-Fragment-2") {
        Dependency("SomeOtherDependency", SomeOtherDependency.init)
    } requires: {
        Requirement(.name("SomeDependency"))
    }
}
```
[1] The classes defined above need not be final.
[2] The container merging operation may throw errors.

#### DependencyContainer Merge Policy
The container merging operation may produce errors, due to conflicting dependency definitions. By default, any and all dependency conflicts are resolved by throwing an `Error`. If a custom merging behaviour is needed it must be defined as an instance conforming to the `DependencyContainerMergePolicy` protocol. This instance must then be passed as an argument to the `DependencyContainer.compose` static factory function or the corresponding initializer: `DependencyContainer.init(name: String, merging containers: [DependencyContainer], using mergePolicy: DependencyContainerMergePolicy = ErrorThrowingMergePolicy())`.

For example, if the required merge policy is to ignore both conflicting dependencies when a merge conflict occurs, one could define the following merge policy:
```swift
struct IgnoreConflictingDependenciesMergePolicy: DependencyContainerMergePolicy {
    
    func resolveConflict(
        between first: (container: DependencyContainer, dependency: Dependency),
        and second: (container: DependencyContainer, dependency: Dependency)) throws -> DependencyConflictResolution {
            return .useNeither
    }
}
```

Resolving conflicts may require to examine the definition of both dependencies and select the one to use. Alternatively, both dependencies may be used if one of them is modified to have a lower priority. If both dependencies are used with the same priorities the conflict will remain and an error will be thrown.

### DependencyGraph

The dependency graph is a globally accessible set of dependencies that are retrieved by activating a specific dependency container. As the dependency graph is globally retained, activating a dependency container is a **destructive** operation that invalidates the existing dependency graph. The default `DependencyContainer` type is immutable by design, and although custom dependency containers are supported for activation by the dependency graph, runtime mutations of a container and the dependency graph should be avoided.

All types of injections are performed via the dependency graph, and in the case of automatic injection provided by the library the globally shared dependency graph is used.

Dependency container activation examples:
```swift
final class SomeDependency {
    init(){}
}

// Activate a dependency container declaratively.
try DependencyGraph.activate {
    
    try DependencyContainer.compose(name: "Tutorial") {
    
        DependencyContainer("Tutorial-Fragment-1") {
            Dependency("SomeDependency", SomeDependency.init)
        } requires: {
            Requirement(.name("SomeDependency"))
        }
        
    }
    
}

// ⚠️ Mutable containers are possible, but should be avoided
class MutableDependencyContainer: DependencyContaining {
    var dependencies: [Dependency] = []
    var requirements: [Requirement] = []
    
    init(){}
}

let mutableDependencyContainer = MutableDependencyContainer()

// Activate container
try DependencyGraph.activate(container: mutableDependencyContainer)

// Mutate container
mutableDependencyContainer.dependencies.append(
    Dependency("SomeDependency", SomeDependency.init)
)

// Activate container again to rebuild the graph
try DependencyGraph.activate(container: mutableDependencyContainer)
```

#### Injection

As mentioned above, all injection requests are performed on `DependencyGraph` instances and all injection requests that are performed automatically by the library use the currently active dependency graph, which is retained in the static property `DependencyGraph.active`.

Dependencies an be injected at their injection site either by name, or by type. Function and property dependencies can be explicitly injected by providing their name and type, or implicitly by using their name or type depending on how they were declared.

##### Injection By Name

A dependency can be injected by name like:

```swift
// By using DependencyGraph
let graph = DependencyGraph.active
let someDependency: SomeDependency = try! graph.inject(named: "name")
let someOtherDependency: SomeOtherDependency = try! graph.inject(named: "otherName", parameters: ["parameter-1", "parameter-2"])

// By using @Injected property wrapper
class PropertyInjectionExample {
    @Injected("name")
    var dependency: SomeDependency
    
    init() {}
}

class ArgumentInjectionExample {
    var dependency: SomeOtherDependency
    
    init(dependency: SomeOtherDependency) {
        self.dependency = dependency
    }
    
    func someMethod(dependency: SomeOtherDependency) {}
}

extension ArgumentInjectionExample {
    convenience init() {
        @Injected("otherName", parameters: "parameter-1", "parameter-2")
        var dependency: SomeOtherDependency
        
        self.init(dependency: dependency)
    }
    
    func someMethod() {
        @Injected("otherName", parameters: "parameter-1", "parameter-2")
        var dependency: SomeOtherDependency
        
        self.someMethod(dependency: dependency)
    }
}

```
[1] The declaration of the dependency container is omitted. For this example assume all dependencies are declared by name.

##### Injection By Type

A dependency can be injected by name like:

```swift
// By using DependencyGraph
let graph = DependencyGraph.active
let someDependency: SomeDependency = try! graph.inject()
let someOtherDependency: SomeOtherDependency = try! graph.inject(parameters: ["parameter-1", "parameter-2"])

// By using @Injected property wrapper
class PropertyInjectionExample {
    @Injected
    var dependency: SomeDependency
    
    init() {}
}

class ArgumentInjectionExample {
    var dependency: SomeOtherDependency
    
    init(dependency: SomeOtherDependency) {
        self.dependency = dependency
    }
    
    func someMethod(dependency: SomeOtherDependency) {}
}

extension ArgumentInjectionExample {
    convenience init() {
        @Injected(parameters: "parameter-1", "parameter-2")
        var dependency: SomeOtherDependency
        
        self.init(dependency: dependency)
    }
    
    func someMethod() {
        @Injected(parameters: "parameter-1", "parameter-2")
        var dependency: SomeOtherDependency
        
        self.someMethod(dependency: dependency)
    }
}

```
[1] The declaration of the dependency container is omitted. For this example assume all dependencies are declared by type.

##### Property Injection

A property dependency can be injected by name and type, like:

```swift
// By using DependencyGraph
let graph = DependencyGraph.active
let someProperty: PropertyImplementation<Bool> = try! graph.injectProperty(named: "someProperty")

```
[1] The declaration of the dependency container is omitted.

##### Function Injection

A function dependency can be injected by name and type, like:

```swift
// By using DependencyGraph
let graph = DependencyGraph.active
let someFunction: (String) -> Bool = try! graph.injectFunction(named: "someFunction")

```
[1] The declaration of the dependency container is omitted.

### Injection Notifications

In cases that a dependency instance needs to be notified for injection events, it may conform to either the `PostInstantiationNotified` or `PreInjectionNotified` protocols. The `PostInstantiationNotified` protocol can be used to notify a dependency instance immediately after it has been instantiated (or retrieved) by the dependency instantiator. Similarly the `PreInjectionNotified` protocol can be used to notify a dependency instance just before it is injected. It should be noted that these notifications run synchronously, and performing blocking or long tasks will block the thread that requested the injection.

### Synthetic Types

Another feature are synthetic types, which are template types with their implementation generated at runtime, by utilizing property and function dependencies. A synthetic type can be created by conforming any type to the `UnsafeSyntheticType` protocol. This protocol has a number of methods that enable the synthesis of synthetic properties and functions. Alternatively, instead of using the `synthesize` methods, implementations of properties and functions can be retrieved in a declarative manner by using the `@SyntheticProperty` property wrapper and the `@SyntheticFunction` result builder.

#### Warning
Synthetic types are a potentially unsafe feature that could result in runtime errors, so please use them only in cases when the requirements of a synthetic type, will always be **undeniably** and **veryfiably**, defined within the active dependency graph.

```swift
// Example of synthetic type using the `synthesize` methods:
final class SyntheticTypeExample: UnsafeSyntheticType {
    static let propertyName = "syntheticProperty"
    static let functionName = "syntheticFunction"
    static let otherFunctionName = "otherSyntheticFunction"
    
    private lazy var _property: PropertyImplementation<String> = synthesize(property: SyntheticTypeExample.propertyName)
    
    var property: String {
        get {
            _property.value
        }
        set {
            _property.value = newValue
        }
    }
    
    func function() -> String {
        synthesizeInvocation(function: SyntheticTypeExample.functionName)
    }
    
    func otherFunction(parameter1: String, parameter2: Int) -> String {
        synthesizeInvocation(function: SyntheticTypeExample.otherFunctionName, parameter1, parameter2)
    }
}

// Example of synthetic type using the declarative API components:
final class SyntheticTypeExample: UnsafeSyntheticType {
    static let propertyName = "syntheticProperty"
    static let functionName = "syntheticFunction"
    static let otherFunctionName = "otherSyntheticFunction"
    
    @SyntheticProperty(SyntheticTypeExample.propertyName)
    var property: String
    
    @SyntheticFunction
    func function() -> String {
        FunctionInvocation<Void, String>(SyntheticTypeExample.functionName)
    }
    
    @SyntheticFunction
    func otherFunction(parameter1: String, parameter2: Int) -> String {
        FunctionInvocation<(String, Int), String>(SyntheticTypeExample.otherFunctionName, parameter1, parameter2)
    }
}
```

### Configuration

The Stitcher library has a couple of configuration options to control the system behaviour while also providing a possible 
extension point for using a custom dependency storage data structure.

#### Options

The library configration has two configurable options:
1. `validateDependencyGraph` which controls whether or not an activated container is validated or not.
2. `warnUnsafeSyntheticTypeUsage` which controls whether or not the library will issue warnings for the usage of the Sythnetic Type feature.

```swift
// Setting configuration options
Stitcher.configuration.validateDependencyGraph = true
Stitcher.configuration.warnUnsafeSyntheticTypeUsage = false
```

#### Custom Dependency Storage

The configuration data structure also contains a factory method that acts as an extension point, in order to provide custom implementations of the `DependencyStorage` used by the active dependency graph. By default, the library ships with an array backed dependency storage `ArrayDependencyStorage` and an hashmap based indexed `IndexedDependencyStorage`. It should be noted that `IndexedDependencyStorage` is an **untested / experimental implementation** and should _**NOT**_ be used at the moment.

```swift
// Declare a custom DependencyStorage type
final class MyCustomDependencyStorage: DependencyStorage {
    
    public func append(_ dependency: Dependency) {}
    
    public func remove(_ dependency: Dependency) {}
    
    public func contains(_ dependency: Dependency) -> Bool {}
    
    public func find(matching queries: [DependencyLocatorQuery]) -> [Dependency] {}
}

// Configure Stitcher to use the custom storage
Stitcher.configuration.storageFactory = {
    MyCustomDependencyStorage()
}
```





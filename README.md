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
- Composable dependency management support for modular projects.
- Supports for injection by name, by type and by associated values.
- Type safe initialization parameters for dependency initialization.
- Support for indexing dependencies in order to minimize injection time.
- Dynamic cyclic dependency detection at runtime.

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

## Dependency Container

A `DependencyContainer` is a data structure that owns a set of dependencies. A container can be created by registering dependencies or by
merging multiple other dependency containers. Dependencies can be registered in a container using a provider closure that builds the registrar of the container. The provider closure uses a result builder to compose the dependencies of a container, with support for conditional statements and grouping. The builder supports different types of components, with the most common being the `DependencyGroup` and `Dependency`.

```swift

DependencyContainer {

    Dependency {
        LocalStorageService()
    }
    
    if AppModel.shared.isPrincipalPresent {
        Dependency {
            UserAccountService()
        }
    }
    
    DependencyGroup {
    
        Dependency {
            AuthenticationService()
        }
        
    }
    .enabled(AppModel.shared.canUseAuthentication)

}

```

In order to invalidate the contents of the dependency container, after a value changes, you can directly use properties of objects with the `@Observable` macro or instead use an `ObservableObject` or any publisher to manually invalidate them. Manual invalidation uses a pseudo-modifier method called invalidated.

Manual invalidation of a container:

``` swift

// Invalidate the dependency container when the shared instance of AppModel changes:
DependencyContainer {

    if ObservableModel.shared.isLoggedIn {
        Dependency {
            LogoutService()
        }
    }

}
.invalidated(tracking: ObservableModel.shared)

// Invalidate the dependency container when the authenticationStateChangedPublisher receives an event:

DependencyContainer {

    if ObservableModel.shared.isLoggedIn {
        Dependency {
            LogoutService()
        }
    }

}
.invalidated(tracking: authenticationStateChangedPublisher)

```

Dependency contaners are reference types, so the invalidation can be attached to any container as long as we have a reference to it,
even if it is already activated or managed by the `@Dependencies` property wrapper. When using manual invalidation with observable 
objects or publishers, please keep in mind that continously or frequently invalidating a dependency container can result in deteriorated performance.

After defining a dependency container it has to be activated in order for the dependencies it contains to be available for injection. Managed
dependency containers have their lifetime automatically managed, while unmanaged containers must manually manage their activation and
deactivation. 

Managed dependency containers can be defined by using the `@Dependencies` property wrapper and will be active as long as the wrapped property is
not deallocated. Changing the value of the property will deactivate the old value and activate the new one. Creating a managed container simply
requires wrapping a dependency container using the property wrapper:

```swift

@Dependencies
var container = DependencyContainer {}

```

Unmanaged containers, are dependency containers that are defined without using the `@Dependencies` property wrapper. After defining an unmanaged
container, it has to be activated manually by using the activation / deactivation methods defined in `DependencyGraph`. Deactivation must be also be
manually managed, especially if the container has a very specific lifetime, for example if it should be active only while a user is not logged in.

```swift

let container = DependencyContainer {}

// Manually activate a container
DependencyGraph.activate(container)

// Manually deactivate a container
DependencyGraph.deactivate(container)

```

### Dependency Registration

Dependencies can be registered by using the `Dependency` struct, a primitive component used to define a single dependency.
Different initializers can be used to denote the way the dependency will be located, while modifying the scope and eagerness of the dependency
can be achieved by using modifier-like methods on the dependency struct.

In order to initialize the `Dependency` struct, at the very least a factory function must be provided which is used to instantiate the dependency.
The function can have an arbitrary number of parameters and as the definition uses parameter packs under the hood, there is no
concrete upper limit to the number of parameters.

```swift

Dependency {
    Service()
}

Dependency { cache in
    RemoteRepository(cachedBy: cache)
}

Dependency { firstParameter, secondParameter in
    SomeService(firstParameter, secondParameter)
}

```

Optional configuration parameters, such as setting the way the dependency is located, it's scope and it's eagerness will be discussed in the following sections.

#### Register Dependencies By Name

By default, dependencies are registered and located by their type. Alternatively, dependencies may also be located by a name, which can be
any string value. If multiple dependencies are defined for the same name in the same container, only one will be used and the rest will be discarded.

```swift

// Setting a name via initializer

Dependency(named: "service") {
    Service()
}

Dependency(named: "repository") { cache in
    RemoteRepository(cachedBy: cache)
}

Dependency(named: "some-service") { firstParameter, secondParameter in
    SomeService(firstParameter, secondParameter)
}

// Setting a name via modifier

Dependency(named: "service") {
    Service()
}
.named("service")

Dependency { cache in
    RemoteRepository(cachedBy: cache)
}
.named("repository")

Dependency { firstParameter, secondParameter in
    SomeService(firstParameter, secondParameter)
}
.named("some-service")

```

The name initializers and the the `named` dependency modifiers also have overloads that can be used with types that conform to
either `RawRepresentable` or `CustomStringConvertible` in order to avoid using raw string values directly. In cases where the dependency
must be located by name, but the name representing type is not easily covnertible to string, associated values may be used instead which
require that the representation type conforms to `Hashable`.

#### Register Dependencies By Type

When using the `Dependency` struct by default the dependency is registered and located by it's type.
However, sometimes it may be required to locate a dependency not by it's exact type, but by a protocol it conforms to, or a superclass it
inherts from. Adding related type definitions to a dependency registration can be achieved by using the appropriate `Dependency` struct initializer
or a modifier method.

```swift

// Setting a related type via initializer

Dependency(conformingTo: ServiceProtocol.self) {
    Service()
}

Dependency(inheritingFrom: ServiceSuperclass.self) {
    Service()
}

// Setting a related type via modifier

Dependency {
    Service()
}
.conforms(to: ServiceProtocol.self)

Dependency {
    Service()
}
.inherits(from: ServiceSuperclass.self)

```

Adding a conformance or inheritance to a dependecy that is of an unrelated type, will produce a runtime error in DEBUG builds.

#### Register Dependencies By Associated Value

Similar to registering a dependency by name, a dependency can also be registered by an associated value. The associated value must conform to 
the `Hashable` protocol. If multiple dependencies are defined for the same hashable value in the same container, only one will be used and
the rest will be discarded.

```swift

// Setting an associated value via initializer

Dependency(for: Services.service) {
    Service()
}

// Setting an associated value via modifier

Dependency {
    Service()
}
.associated(with: Services.service)

```

When using associated value located dependencies, having a fast and collision free hashable implementation can make a significant difference in
performance.

#### Dependency Scope

The scope of a dependency controls how it's lifetime is managed by the dependency graph once instantiated.
The following four scopes are available:

| Scope | Lifetime |
| - | - |
| Instance    | A different instance will be used every time is it injected. |
| Shared      | The same instance of the dependency will be used every time is it injected, as long as there are strong references to it. |
| Singleton   | The same instance of the dependency will be used every time is it injected. |
| Managed     | The same instance of the dependency will be used every time is it injected, until the given publisher fires. |

By default, the scope of a dependency is automatically resolved, based on whether the type of the dependency is a value type or a reference
type. The scope automatically selected for value types is `.instance`, while for reference types `.shared` is used. Furthermore, as value types
cannot be reference counted, using the `.shared` scope with a value type is equivalent to using the `.instance` scope.

The scope of a dependency can be set using the `scope` dependency modifier:

```swift

Dependency {
    SomeService()
}
.scope(.instance)

Dependency {
    EventTrackingService()
}
.scope(.shared)

Dependency {
    Repository()
}
.scope(.singleton)

Dependency {
    UserAccountManager()
}
.scope(.managed(by: principalChangedPublisher))

```

#### Dependency Eagerness

By default, dependencies are lazily instantiated when first required for injection. There are some cases, such as a singleton event tracking
service for example, that require the dependency to be instantiated when it's dependency container is activated in order to be able to receive events
immediately. To enable this behaviour the `eagerness` dependency modifier can be used, so that the `DependencyGraph` will instantiate the dependency
when the dependency container will be activated.

```swift

Dependency {
    EventTracker()
}
.eagerness(.eager)

```

#### Dependency Groups

As discussed in a previous section, conditional dependency registrations can conditionally provide dependencies based on the state of the system.
However, if several dependencies are conditionally enabled based on the same state it may be helpful to group them together and conditionally enable
the entire group. A dependency group can be initialized by passing a provider closure that builds the registrar of the group.

```swift

DependencyContainer {

    DependencyGroup {
        
        MotionDetectionService()
        
    }
    .enabled(System.isGyroscopeSupported)

}

```

Enabling or disabling a dependency group can be achieved using the `enabled` dependency group modifier.

#### Other Registration Representations

Other than using the `Dependency` and `DependencyGroup` structs while building dependency containers, two more components that are representations of
registrations can be used to register dependencies. 

##### Autoclosure Registration Component

The first registration representing component are provider autoclosures, which can be used as a convenience for registering type located dependencies
with zero parameter initializers.

```swift

DependencyContainer {
    
    SomeService()
    
    Dependency {
        SomeService()
    }

}

```

The two registrations above are equivalent. The autoclosure from the first dependency **will not be invoked** when the provider closure is evaluated,
but when the dependency is instantiated by the dependency graph.

##### DependencyRepresenting Registration Component

Completely custom dependency registration types can also be used with a dependency container. The custom registration type must conform to the
`DependencyRepresenting` protocol. The protocol has four requirements to define the characteristics of the dependency, three of them are optional
and define the dependency locator, scope and eagerness. The fourth requirement is a property called `dependencyProvider`, which must provide a function
that will be used to instantiate the dependency.

```swift

struct RepositoryDependency: DependencyRepresenting {
    
    var locator: DependencyLocator {
        .name(Self.name)
    }
    
    var scope: DependencyScope {
        .singleton
    }
    
    var eagerness: DependencyEagerness {
        .eager
    }
    
    var dependencyProvider: DependencyFactory.Provider<Repository> {
        DependencyFactory.Provider { cache in
            Repository(cachedBy: cache)
        }
    }
    
    static let name = "repository"
}

@Dependencies
var container = DependencyContainer {
    RepositoryDependency()
}

@Injected(name: RepositoryDependency.name)
var repository: Repository

```

### Multiple Dependency Containers

In modular applications, it is possible to have different portions of the system segregated to smaller subsystems. In order to support this paradigm,
it is possible to use multiple dependency containers, either by having multiple (managed or unmanaged) containers active at the same time, or by
merging each subsystem container into a composite dependency container.

```swift

let containers: [DependencyContainer] = makeContainers()
let container = DependencyContainer(merging: containers)

```

Please note that the merged containers are strongly retained by the composite dependency cotnainer in order to correctly propagate observations.

## Dependency Graph

The dependency graph represents a composite of all active dependency containers along with additional storage to store dependency instances.
Furthermore, it is responsible for handling the activation, indexing and deactivation of dependency containers. 

Upon activating a dependency container, and depending on the options defined in `StitcherConfiguration` the dependency graph can index the registrar
of a container in order to minimize the search time for dependencies during injection. During indexing, any eager dependencies are instantiated and
stored for future use. If indexing is disabled, eager dependencies are instantiated immediately after activation. 

Please note that indexing and eager dependency initialization is performed asyncronously as the operation directly depends on the size of the
dependency container. If this operation must be awaited then the async variant of the `activate` method can be used instead. For managed containers,
use the `setContainer` method of the `@Dependencies` propert wrapper. In general, in order to improve performance during indexing, prefer using
multiple small containers that are activated independently of each other.

### Automatic Injection

Automatic injection is performed by using the `@Injected` property wrapper. When using this property wrapper the dependency is injected lazily at the
time when it was first requested which can be helpful for defining cyclic relationships between dependencies.

The injected property wrapper will attempt to inject the dependency, the first time it's wrapped value is requested. If the dependency cannot be found
or it has a mismatching type it will cause a runtime precondition failure, which will print the file and line of the failure.

#### Inject By Name

Dependencies can be injected by using the same name they were registered with in their dependency container. The registered dependency type must be
convertible to the type of the wrapped property by type casting.

Injecting dependencies by name requires the use of the appropriate Injected initializer. The first argument has the label of `name` and defines
the name the dependency will be located with. After the first argument of the initializer, the rest of the arguments are parsed as instantiation
parameters used to instantiate the dependency.

```swift

enum Services: String {
    case service
    case repository
}

@Dependencies
var container = DependencyContainer {
    
    Dependency {
        Service()
    }
    .named(Services.service)
    
    Dependency { context in
        Repository(managedObjectContext: context)
    }
    .named(Services.repository)
}

@Injected(name: Services.service)
var service: Service

@Injected(name: Services.repository, ManagedObjectContexts.repositoryContext)
var repository: Repository

```

#### Inject By Type

//


#### Inject By Associated Value

Dependencies can be injected by using the same hashable value they were registered with, in their dependency container. The registered dependency type
must be convertible to the type of the wrapped property by type casting.

Injecting dependencies by associated values requires the use of the appropriate Injected initializer. The first argument has the label of `value` and
defines the value will be located with. After the first argument of the initializer, the rest of the arguments are parsed as instantiation parameters
used to instantiate the dependency. The hashvalue of the given value must not change for different instances representing the same dependency.

```swift

protocol UploadLocation: Hashable {}

class ProfileAvatarLocation: UploadLocation {}
class ProfileBannerLocation: UploadLocation {}

struct Model<T>: Hashable {}

@Dependencies
var container = DependencyContainer {
    
    Dependency {
        ProfileAvatarUploadService()
    }
    .associated(with: ProfileAvatarLocation())
    
    Dependency {
        ProfileBannerUploadService()
    }
    .associated(with: ProfileBannerLocation())
    
    Dependency { context in
        UserRepository(managedObjectContext: context)
    }
    .associated(
        with: Model(
            of: User.self
        )
    )
}

@Injected(value: ProfileAvatarLocation())
var avatarUploadService: UploadServiceProtocol

@Injected(value: ProfileBannerLocation())
var bannerUploadService: UploadServiceProtocol

@Injected(value: Model(of: User.self), ManagedObjectContexts.usersContext)
var userRepository: UserRepository

```

Name
Simple types / protocol / superclass, optional type, collections
Value

### Manual Injection

Name
Simple types / protocol / superclass, optional type, collections
Value

### Dependency Cycles

// cycle detection and avoidance

## Interoperabilty

// aware protocol, graphChangedPublisher, autoreloading, config




////

Topics:

DependencyContainer

Registration by name, by type, by value

DependncyGraph

Inject by name, by type, by value

Configuration


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





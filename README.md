# Stitcher

Stitcher is a dependecy injection library for Swift projects.

- [Stitcher](#stitcher)
  - [✔️ Minimum Requirements](#️-minimum-requirements)
  - [⏱ Version History](#-version-history)
  - [🧰 Features](#-features)
  - [📦 Installation](#-installation)
    - [Swift Package](#swift-package)
    - [Manually](#manually)
  - [⚡️ Quick Start](#️-quick-start)
  - [📋 Library Overview](#-library-overview)
    - [Dependency Container](#dependency-container)
      - [Dependency Registration](#dependency-registration)
        - [Register Dependencies By Name](#register-dependencies-by-name)
        - [Register Dependencies By Type](#register-dependencies-by-type)
        - [Register Dependencies By Associated Value](#register-dependencies-by-associated-value)
        - [Dependency Scope](#dependency-scope)
        - [Dependency Eagerness](#dependency-eagerness)
        - [Dependency Groups](#dependency-groups)
        - [Other Registration Representations](#other-registration-representations)
          - [Autoclosure Registration Component](#autoclosure-registration-component)
          - [DependencyRepresenting Registration Component](#dependencyrepresenting-registration-component)
      - [Multiple Dependency Containers](#multiple-dependency-containers)
    - [Dependency Graph](#dependency-graph)
      - [Automatic Injection](#automatic-injection)
        - [Inject By Name](#inject-by-name)
        - [Inject By Type](#inject-by-type)
        - [Inject By Associated Value](#inject-by-associated-value)
      - [Manual Injection](#manual-injection)
      - [Dependency Cycles](#dependency-cycles)
    - [Interoperabilty](#interoperabilty)
      - [PostInstantiationAware Hook](#postinstantiationaware-hook)
      - [DependencyGraph Change Observations](#dependencygraph-change-observations)
      - [Configuration](#configuration)



## ✔️ Minimum Requirements

Stitcher requires at least **iOS 13, macOS 10.15, tvOS 13** or **watchOS 6** and **Swift version 5.9**.
The minimum OS versions may be dropped in a future release as the main dependency from these versions is `Combine`.

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

## 📋 Library Overview

### Dependency Container

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

#### Dependency Registration

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

##### Register Dependencies By Name

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

##### Register Dependencies By Type

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

Adding a conformance or inheritance to a dependecy that is of an unrelated type, will result in an error when attempting to inject the dependency.

##### Register Dependencies By Associated Value

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

##### Dependency Scope

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

##### Dependency Eagerness

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

##### Dependency Groups

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

##### Other Registration Representations

Other than using the `Dependency` and `DependencyGroup` structs while building dependency containers, two more components that are representations of
registrations can be used to register dependencies. 

###### Autoclosure Registration Component

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

###### DependencyRepresenting Registration Component

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

#### Multiple Dependency Containers

In modular applications, it is possible to have different portions of the system segregated to smaller subsystems. In order to support this paradigm,
it is possible to use multiple dependency containers, either by having multiple (managed or unmanaged) containers active at the same time, or by
merging each subsystem container into a composite dependency container.

```swift

let containers: [DependencyContainer] = makeContainers()
let container = DependencyContainer(merging: containers)

```

Please note that the merged containers are strongly retained by the composite dependency cotnainer in order to correctly propagate observations.

### Dependency Graph

The dependency graph represents a composite of all active dependency containers along with additional storage to store dependency instances.
Furthermore, it is responsible for handling the activation, indexing and deactivation of dependency containers. 

Upon activating a dependency container, and depending on the options defined in `StitcherConfiguration` the dependency graph can index the registrar
of a container in order to minimize the search time for dependencies during injection. During indexing, any eager dependencies are instantiated and
stored for future use. If indexing is disabled, eager dependencies are instantiated immediately after activation. 

Please note that indexing and eager dependency initialization is performed asyncronously as the operation directly depends on the size of the
dependency container. If this operation must be awaited then the async variant of the `activate` method can be used instead. For managed containers,
use the `setContainer` method of the `@Dependencies` propert wrapper. In general, in order to improve performance during indexing, prefer using
multiple small containers that are activated independently of each other.

#### Automatic Injection

Automatic injection is performed by using the `@Injected` property wrapper. When using this property wrapper the dependency is injected lazily at the
time when it was first requested which can be helpful for defining cyclic relationships between dependencies.

The injected property wrapper will attempt to inject the dependency, the first time it's wrapped value is requested. If the dependency cannot be found
or it has a mismatching type it will cause a runtime precondition failure, which will print the file and line of the failure.

##### Inject By Name

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

##### Inject By Type

The default way to register and inject dependencies is by their type, or a supertype related by a protocol conformance or by inheritance.
Other that using the dependency type directly a few common types are also supported:

1. Optional
   Injects a dependency that matches the `Wrapped` type, or nil if no such dependency is found.
   
2. Arrays
   Injects *all* dependencies that match the `Element` type, or an empty collection if no such dependencies are found.

```swift

class AccountRepository: PrincipalAware {}

class AccountSettingsRepository: PrincipalAware {}

@Dependencies
var container = DependencyContainer {
    Dependency {
        AccountRepository()
    }
    .conforms(to: PrincipalAware.self)
    
    Dependency {
        AccountSettingsRepository()
    }
    .conforms(to: PrincipalAware.self)
}

@Injected
var accountRepository: AccountRepository

@Injected
var accountRepository: AccountRepository?

@Injected
var principalAwareServices: [PrincipalAware]

```

##### Inject By Associated Value

Dependencies can be injected by using the same hashable value they were registered with, in their dependency container. The registered dependency type
must be convertible to the type of the wrapped property by type casting.

Injecting dependencies by associated values requires the use of the appropriate Injected initializer. The first argument has the label of `value` and
defines the value will be located with. After the first argument of the initializer, the rest of the arguments are parsed as instantiation parameters
used to instantiate the dependency. The hashvalue of the given value must not change for different instances representing the same dependency.

```swift

enum UploadLocation: Hashable {
    case avatar
    case banner
}

struct Entity<T>: Hashable {}

@Dependencies
var container = DependencyContainer {
    
    Dependency {
        ProfileAvatarUploadService()
    }
    .associated(with: UploadLocation.avatar)
    
    Dependency {
        ProfileBannerUploadService()
    }
    .associated(with: UploadLocation.banner)
    
    
    Dependency { context in
        UserRepository(managedObjectContext: context)
    }
    .associated(
        with: Entity(
            of: User.self
        )
    )
}

@Injected(value: UploadLocation.avatar)
var avatarUploadService: UploadServiceProtocol

@Injected(value: UploadLocation.banner)
var bannerUploadService: UploadServiceProtocol

@Injected(value: Model(of: User.self), ManagedObjectContexts.usersContext)
var userRepository: UserRepository

```

#### Manual Injection

Manual injection follows the same principles as automatic injection, but allows for handling errors during injection instead of runtime errors.
In contrast to automatic injection, manual injection is eager, meaning that the dependency will be instantiated immediately when requested.
Injecting an arbitrary dependency can be achieved by using the `inject` family of methods of `DependencyGraph`.

```swift

@Dependencies
var container = DependencyContainer {
    
    Dependency {
        AccountService()
    }
    .named("account-service")
    
    Dependency { context in
        UserRepository(managedObjectContext: context)
    }
    
    Dependency {
        ImageUploadService()
    }
    .associated(with: UploadServices.images)
}

let accountService: AccountService = try DependencyGraph.inject(byName: "account-service")
let userRepository: UserRepository = try DependencyGraph.inject(byType: UserRepository.self, ManagedObjectContexts.usersContext)
let imageUploadService: ImageUploadService = try DependencyGraph.inject(byValue: UploadServices.images) 

```

#### Dependency Cycles

Cyclic dependency relationships are relationships between two types, that depend on each other during initialization. For example, given a primary type
named `Root` and a secondary type named `Leaf`, root has a property of the leaf type that must be set during initialization and conversely leaf type
has a property of root type that must be set during initialization. When trying to initialize these two types, an endless recursive loop will occur,
as in order to instantiate root, you have to instantiate leaf and in order to instantiate leaf, you have to instantiate root.

In order to avoid these cycles it is recommended to lazily inject the dependencies either by using the `@Injected` property wrapper or by invoking the
manual injection methods of `DependencyGraph` when the property is first accessed. Stitcher has a runtime dependency cycle detection feature that
detects these cycles and emits a descriptive error with the entire cycle mapped out, regardless of it's depth so they can be detected and resolved.

```
// InjectionError description when a cycle is detected:
Dependency cycle detected, Type[Root] -> Type[Leaf] -> Type[Root].

```

The above error has the root type and all dependency instantiations performed in the same context so the cycle can be easily tracked and corrected.

### Interoperabilty

Stitcher has a few interoperability access points, in order to configure the behaviour of the library or receive updates on state changes.

#### PostInstantiationAware Hook

The `PostInstantiationAware` protocol can be used to hook into the initialization of dependencies by the `DependencyGraph` in order to perform various
actions, such as resource loading, injecting lazy dependencies etc. It has a single requirement, a function called `didInstantiate`, which is invoked
by the dependency graph after a dependency is instantiated, but before it is injected.

```swift

class EventTrackingService: PostInstantiationAware {
    
    init() {}
    
    func didInstantiate() {
        sendEvent(named: "App started")
    }
    
    func sendEvent(named: String) {}
}

@Dependencies
var container = DependencyContainer {
    Dependency {
        EventTrackingService()
    }
    .scope(.singleton)
    .eagerness(.eager)
}

```

Please note, that there is *no guarantee* of the thread that will invoke the `didInstantiate` method, so using this hook to perform UI updates without
first dispatching to the main thread, may lead to unexpected behaviours or even crashes.

#### DependencyGraph Change Observations

As dependency containers are activated, invalidated or deactivated the dependencies available to the dependency graph may change. In order to reload
any dependencies at that time an observation is needed. The dependency graph has a publisher, that fires whenever the available dependencies are
invalidated or changed, called `graphChangedPublisher`.

In order to alter any automatically injected dependencies in the event of a dependency graph change, there are the following helper functions defined
in the `@Injected` property wrapper that can be of use:

1. The `loadIfNeeded` function
   Loads the injected dependency if it is not already loaded, or if the loaded value is nil or an empty collection.
2. The `reload` function
   Reloads the injected dependency.
3. The `autoreload` function
   Automatically reloads the injected dependency after *every* change of the dependency graph.

#### Configuration

The behaviour of Stitcher can be configured using the properties defined in the `StitcherConfiguration` enum.

| Option | Behaviour |
| - | - |
| isIndexingEnabled | Controls whether indexing of dependency containers is active. An unindexed container may have slower performance when looking up dependencies |
| approximateDependencyCount | An approximate count of the number of defined dependencies used to optimize memory allocations during indexing |
| autoCleanupFrequency | The frequency with which the instance storage of the dependency graph releases unused or empty storage entries |

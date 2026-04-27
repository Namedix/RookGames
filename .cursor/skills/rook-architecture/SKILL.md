---
name: rook-architecture
description: Conventions for the Rook iOS app — Tuist 4, SwiftUI, iOS 26, Point-Free modern SwiftUI stack (Dependencies, Sharing, SwiftNavigation, Tagged, IdentifiedCollections). Use whenever editing or generating Swift, adding a feature, modifying Project.swift or Tuist/Package.swift, or scaffolding new screens. Mirrors pointfreeco/syncups.
---

# Rook architecture skill

This skill is the source of truth for any code, file, or configuration change in
this repo. Read it before adding features, refactoring, or wiring up new
screens. The architecture deliberately mirrors
[pointfreeco/syncups](https://github.com/pointfreeco/syncups) — when in doubt,
consult that repo for an analogous pattern.

## Hard rules (do not violate)

1. **Minimum iOS target is iOS 26.** Do not bump it down. Set in
   `Project.swift` as `.iOS("26.0")`. Use modern APIs freely (`@Observable`,
   `NavigationStack`, `Bindable`, `@Entry`, etc.).
2. **No tests.** Do not create `RookTests`, `*Tests.swift`, `XCTest`, or `Swift
   Testing` files. Do not add a test target to `Project.swift`. Do not add
   `withDependencies` test scaffolding *as tests*. Previews are fine.
3. **No `XCTestDynamicOverlay` / `IssueReporting` test affordances** beyond what
   `swift-sharing` already exposes (`isTesting`). Do not add `unimplemented`,
   `XCTFail`-style fakes, or test plans.
4. **Tuist is the build system.** Never hand-edit `*.xcodeproj` —
   they are generated and gitignored. All target/dependency changes go through
   `Project.swift` and `Tuist/Package.swift`, then `tuist install && tuist
   generate`.
5. **Swift 6 mode, MainActor for models.** Every `@Observable` feature model is
   `@MainActor final class`. Domain types are `Sendable` `struct`s.

## Architecture (Point-Free "modern SwiftUI", per SyncUps)

### One observable model per screen

```swift
@MainActor
@Observable
final class CountersListModel {
    var addCounter: CounterFormModel?               // sheet state lives on the model
    @ObservationIgnored @Shared(.counters) var counters
    @ObservationIgnored @Dependency(\.uuid) var uuid

    var onCounterTapped: (Shared<Counter>) -> Void = { _ in }   // parent-owned hook

    func addCounterButtonTapped() { … }             // intent methods, never view code
}
```

- Properties named `xxxButtonTapped`, `xxxChanged`, `task`, `onAppear`. No
  `viewDidLoad`, no `ViewModel` suffix.
- `@Dependency` and `@Shared` are always `@ObservationIgnored`.
- Sheets/drill-downs/alerts are `var destination: Destination?` where
  `Destination` is `@CasePathable @dynamicMemberLookup enum`.

### State-driven navigation

The single `AppModel` owns `var path: [Path]` for the `NavigationStack`. The
`Path` enum holds the **child model**, not the value:

```swift
@CasePathable
@dynamicMemberLookup
enum Path: Hashable {
    case detail(CounterDetailModel)
}
```

`AppView` switches over the path inside `.navigationDestination(for:)`:

```swift
NavigationStack(path: $model.path) {
    CountersListView(model: model.countersList)
        .navigationDestination(for: AppModel.Path.self) { path in
            switch path {
            case let .detail(model): CounterDetailView(model: model)
            }
        }
}
```

For per-screen sheets/alerts use `Destination` enums on the screen model and
`$model.destination.alert` / `$model.destination.edit` (SwiftUINavigation
provides the case-path bindings via `@CasePathable @dynamicMemberLookup`).

### Parent-owned navigation, child-exposed hooks

Children **never** push/pop or mutate sibling state. They expose closures:

```swift
// Child:
var onCounterDeleted: (Counter.ID) -> Void = { _ in }

// Parent (AppModel.bind):
detail.onCounterDeleted = { [weak self] id in
    self?.countersList.deleteCounter(id: id)
    _ = self?.path.popLast()
}
```

Re-run `bind()` from `didSet` on `path` and on any child-model property so that
hooks are wired up after deep links and reassignments. See
`Rook/Sources/App/AppModel.swift`.

### Construct children with `withDependencies(from: self)`

```swift
addCounter = withDependencies(from: self) {
    CounterFormModel(counter: Counter(id: Counter.ID(uuid())))
}
```

This propagates dependency overrides into Xcode previews and any future
override scope.

### Persistence via `@Shared` + `FileStorageKey`

Place keys in `Rook/Sources/SharedKeys/`. Mirror SyncUps' pattern, including
the `isTesting`/UI-test guard on the default value:

```swift
extension SharedReaderKey
where Self == FileStorageKey<IdentifiedArrayOf<Counter>>.Default {
    static var counters: Self {
        Self[
            .fileStorage(URL.documentsDirectory.appending(component: "counters.json")),
            default: isTesting || ProcessInfo.processInfo.environment["UI_TEST_NAME"] != nil
                ? []
                : [.mock, .booksReadMock, .coffeeMock]
        ]
    }
}
```

Mutate through `$counters.withLock { … }`. Read shared collections in views
with `Array(model.$counters)` to get `Binding`s per element.

### Type-safe IDs and identified collections

- `typealias ID = Tagged<Counter, UUID>` on every domain type.
- Collections of identifiables are always `IdentifiedArrayOf<T>` (never `[T]`).
- Look up by id: `$counters[id: someID]`.

### Dependencies to use

Stick to the standard `swift-dependencies` keys:

- `\.uuid`, `\.date.now`, `\.continuousClock`, `\.calendar`, `\.locale`,
  `\.timeZone`, `\.openURL`, `\.mainQueue` (Combine schedulers if needed).
- For new side effects (e.g. networking, persistence beyond `@Shared`), add a
  `DependencyKey` in a new file under `Rook/Sources/Dependencies/`.
- Use the `@DependencyClient` macro from `DependenciesMacros` for clients with
  multiple endpoints.

## File layout (extend, do not rearrange)

```
Project.swift
Tuist.swift
Tuist/Package.swift
Rook/Sources/
├── App/                      # @main, AppModel, AppView (one screen at most)
├── Features/<FeatureName>/   # One folder per screen, contains Model + View
├── Models/                   # Domain types (Codable, Hashable, Sendable, Tagged ID)
├── SharedKeys/               # @Shared key extensions
└── Dependencies/             # Custom DependencyKey/DependencyClient definitions
Rook/Resources/Assets.xcassets
```

When adding a new screen `Foo`:

1. Create `Rook/Sources/Features/Foo/FooModel.swift` and `FooView.swift`.
2. If it can be drilled into, add a `case foo(FooModel)` to `AppModel.Path`.
3. If it has its own sub-navigation, add a `Destination` enum to `FooModel`.
4. Wire parent hooks in `AppModel.bind()`.
5. No new target unless absolutely required — the app is one Tuist target.

## Tuist conventions

- External SPM deps go in `Tuist/Package.swift` and are forced to `.framework`
  in `PackageSettings.productTypes` (already configured for the Point-Free
  stack). Reference them in `Project.swift` via `.external(name: "X")`.
- Do not add a separate `Workspace.swift` — the project is single-project.
- Do not commit generated `*.xcodeproj`/`*.xcworkspace` (already in
  `.gitignore`).
- After dependency changes: `tuist install && tuist generate`.

## When asked to "add a feature", default plan

1. Add/extend a domain type in `Models/` with a `Tagged` ID.
2. Add a `@Shared` key in `SharedKeys/` if it needs persistence.
3. Create `Features/<Name>/<Name>Model.swift` (state + intent methods +
   `Destination` if needed + parent hooks as closures).
4. Create `Features/<Name>/<Name>View.swift` (`@Bindable var model:`, no
   business logic, dispatch to `model.xxxButtonTapped()`).
5. Update `AppModel` (path enum case + `bind()` wiring) and `AppView`
   (`navigationDestination` switch).
6. **Stop.** Do not write tests. Do not add CI test steps.

## Anti-patterns (never do these)

- ❌ `class FooViewModel: ObservableObject { @Published … }` — use `@Observable`.
- ❌ `NavigationLink(destination: SomeView())` fire-and-forget — push state via
  `model.path` instead.
- ❌ `FileManager.default.write(...)` directly — use `@Shared` /
  `FileStorageKey`.
- ❌ `UUID()`, `Date()`, `Task.sleep` in feature code — go through
  `@Dependency`.
- ❌ Using `[T]` for identifiable collections — use `IdentifiedArrayOf<T>`.
- ❌ Adding a tests target, `XCTest` import, `@Test`, or `XCTestCase`.
- ❌ Adding new top-level SPM dependencies via Xcode UI — use
  `Tuist/Package.swift`.

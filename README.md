# Rook

iOS 26 SwiftUI app scaffolded with **Tuist 4** and Point-Free's modern SwiftUI stack
(`swift-dependencies`, `swift-sharing`, `swift-navigation`, `swift-tagged`,
`swift-identified-collections`, `swift-case-paths`).

The architecture mirrors [pointfreeco/syncups](https://github.com/pointfreeco/syncups):

- One `@Observable` model per screen, plus a single `AppModel` that owns the
  `NavigationStack` path as `[Path]` with a `@CasePathable` enum.
- All navigation is **state-driven** — sheets, drill-downs and alerts are pieces
  of state on a model. Deep-linking is "just construct the state".
- All side effects flow through `@Dependency` (uuid, date, continuousClock, …).
- All persistence flows through `@Shared` (file storage by default).
- IDs are `Tagged<Counter, UUID>`, collections are `IdentifiedArrayOf<Counter>`.

## Bootstrap

```bash
mise install              # installs Tuist 4.181.x pinned in .mise.toml
tuist install             # resolves SPM packages declared in Tuist/Package.swift
tuist generate            # generates Rook.xcodeproj and opens Xcode
```

If you don't use mise, install Tuist via Homebrew (`brew tap tuist/tuist && brew
install tuist`) — the project pins `4.181.1`.

## Layout

```
Project.swift                # Tuist target definition
Tuist.swift                  # Tuist config
Tuist/
└── Package.swift            # External SPM dependencies (Point-Free libs)
Rook/
├── Sources/
│   ├── App/                 # @main, AppModel (NavigationStack path), AppView
│   ├── Features/
│   │   ├── CountersList/    # Root list + add sheet
│   │   ├── CounterForm/     # Reusable form for new + edit
│   │   └── CounterDetail/   # Drill-down with edit sheet + delete alert
│   ├── Models/              # Domain types (Counter)
│   └── SharedKeys/          # @Shared FileStorageKey extensions
└── Resources/
    └── Assets.xcassets      # AppIcon, AccentColor
```

## Conventions

- **Models hold state, never views.** Views are `struct` with `@Bindable var
  model:` and dispatch to model methods named `xxxButtonTapped()`.
- **Parent owns navigation, child exposes hooks.** Children expose closures
  (`onCounterTapped`, `onCounterDeleted`) that the parent fills in inside
  `bind()` to push/pop and mutate shared state.
- **Use `withDependencies(from: self) { … }`** when constructing a child model
  from a parent so that overridden dependencies propagate (Xcode previews and
  any future test scaffolding rely on this).
- **No tests** — this scaffold is intentionally test-free. See
  `.cursor/skills/rook-architecture/SKILL.md` for the full rule set.

## Dependencies

Pinned in `Tuist/Package.swift` to the same versions used by SyncUps at the time
of writing:

| Package                       | Version  |
|-------------------------------|----------|
| swift-dependencies            | 1.7.0+   |
| swift-sharing                 | 2.2.0+   |
| swift-navigation              | 2.2.3+   |
| swift-identified-collections  | 1.1.1+   |
| swift-case-paths              | 1.6.1+   |
| swift-tagged                  | 0.10.0+  |

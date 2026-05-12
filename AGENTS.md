# WhosTurn - Agent Guidelines

## Project Overview

WhosTurn is a SwiftUI iOS app (iOS 26.0+, Swift 6.2) for randomly picking a person from a configurable team list to present at daily stand-ups or any other scrum ceremony. It uses a modular architecture with local Swift packages.

## Module Hierarchy

```
MainApp (WhosTurnApp)
├── Base SPM Modules
│   ├── WTDesignSystem   — shared UI components and styling
│   ├── WTNetworking     — networking layer (services, session, OAuth, models)
│   ├── WTRouter         — navigation (Coordinator protocol, RouterState, Step definitions)
│   └── WTTools          — utilities (e.g. WTStorage)
└── Feature SPM Modules
    ├── WTPicker         — random presenter picker (selection view, animation, result display)
    └── WTTeamSetup      — team configuration (add/edit/remove members, manage teams)
```

### Feature Module Details

- **WTPicker**: Self-contained random picker feature. Contains the picker screen (View + ViewModel + Datasource) and the selection animation/result display. Depends on Base modules (WTDesignSystem, WTNetworking, WTRouter).
- **WTTeamSetup**: Team and member management flow. Depends on Base modules and WTPicker (to present the picker via the coordinator).

### Import Rules

- **Feature modules** can import Base modules and other Feature modules.
- **Base modules** can only import other Base modules. They must NEVER import Feature modules.
- **MainApp** can import both Base and Feature modules.

## Design Pattern (MVVM + Coordinator + Datasource)

Every feature screen follows this layered pattern. Use `PickerView` in `WTPicker` as the reference implementation.

### 1. View

- Pure SwiftUI. Only imports `SwiftUI` (never `WTNetworking` or other Base modules directly).
- Receives a `ViewModelProtocol` via init with a default concrete instance for convenience.
- Holds a `@Bindable var state: <Feature>ViewState` for two-way bindings if needing bindings else hold the var state: ViewState initializing on the init from the viewModel protocol that we DI on the view.
- Calls ViewModel protocol methods for user actions, if possible all logic of the view is transferred to the viewModel and performed there.

```swift
struct PickerView: View {
    private let viewModel: PickerViewModelProtocol
    @Bindable var state: PickerViewState

    init(viewModel: PickerViewModelProtocol = PickerViewModel()) {
        self.viewModel = viewModel
        self.state = viewModel.state
    }
}
```

### 2. ViewState (`@Observable` class)

- A standalone `@Observable` class holding all UI-bound state.
- Owned by the ViewModel, exposed via its protocol.
- The View binds to this state object directly.

```swift
@Observable
class PickerViewState {
    var members: [TeamMemberUIModel] = []
    var selectedMember: TeamMemberUIModel?
    var isAnimating: Bool = false
    var errorMessage: String?
}
```

### 3. ViewModel (Protocol + Concrete class)

- **Protocol** (`PickerViewModelProtocol`): defines `state` property and all actions the View can call.
- **Concrete class** (`PickerViewModel`): implements the protocol. Handles UI logic (random selection, animation state, history tracking). Does NOT import `WTNetworking` — delegates data fetching to the Datasource.
- Dependencies are injected via init with protocol types and sensible defaults.

```swift
protocol PickerViewModelProtocol {
    var state: PickerViewState { get set }
    @MainActor func onPickPressed()
    @MainActor func loadMembers() async
}

final class PickerViewModel: PickerViewModelProtocol {
    private let datasource: PickerDatasourceProtocol
    // ...
}
```

### 4. Datasource (Protocol + Concrete struct)

- The ONLY layer that imports `WTNetworking`.
- Owns the network service, calls it, and maps network responses to UI models.
- Returns UI-ready models (e.g. `[TeamMemberUIModel]`) — the ViewModel never sees raw API responses.
- Protocol conforms to `Sendable` for safe async usage.

```swift
protocol PickerDatasourceProtocol: Sendable {
    func fetchTeamMembers(teamId: String) async throws -> [TeamMemberUIModel]
}

struct PickerDatasource: PickerDatasourceProtocol {
    private let service: WTTeamService
    // fetches from service, maps response to UI models
}
```

### 5. Coordinator (Protocol + Concrete class)

- Conforms to the `Coordinator` protocol from `WTRouter`.
- Manages navigation via `RouterState` (an `@Observable` class with navigation paths).
- The Coordinator also defines a `Step` enum extension that maps steps to Views.

```swift
public protocol PickerCoordinator: Coordinator { }

public class PickerCoordinatorImp: PickerCoordinator {
    public weak var routerState: RouterState?
    public func navigate(to: any Step) { ... }
}
```

### Layer Responsibilities Summary

| Layer       | Imports              | Responsibility                                      |
|-------------|----------------------|-----------------------------------------------------|
| View        | SwiftUI              | UI rendering, binds to ViewState, calls ViewModel   |
| ViewState   | Observation          | Holds all observable UI state                       |
| ViewModel   | Foundation           | UI logic, coordinates state updates via Datasource  |
| Datasource  | WTNetworking         | Network calls + response-to-UI-model mapping        |
| Coordinator | WTRouter             | Navigation logic                                    |

### Dependency Flow

```
View --> ViewModel (protocol) --> Datasource (protocol) --> WTNetworking Service (protocol)
View --> ViewState (@Observable, via @Bindable)
Coordinator --> RouterState (@Observable)
```

## Protocols & Testability

- Every layer exposes a **protocol** for its public interface.
- Concrete implementations provide **default parameter values** in `init` so call sites stay clean.
- This enables dependency injection of mock implementations in unit tests.

## Code Style

- Swift 6.2 strict concurrency. Use `async/await`, avoid Combine.
- `@MainActor` on ViewModel methods that mutate ViewState.
- `Sendable` conformance on protocols used across concurrency boundaries (e.g. Datasource).
- PascalCase for types, camelCase for properties/methods.
- 4-space indentation.
- UI models are plain structs conforming to `Identifiable` and `Hashable`.

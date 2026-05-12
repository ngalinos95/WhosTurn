// Who’s Turn?

// Who’s Turn is a lightweight, modern iOS app for fairly choosing the next presenter (or any turn-based selection) from your team. It uses a polished design system, smooth animations, and a simple storage layer to provide a delightful experience for teams.

// Built with:
// - Swift 6 and SwiftUI
// - Swift Concurrency (async/await)
// - Modular architecture via Swift Package Manager
// - A custom design system with glass effects and animations

// Features

// - Team management
//   - Add and remove members
//   - Clean, minimal UI for quick setup
// - Fair picker
//   - Weighted random selection based on recent history
//   - Clear visual “spin” animation and confetti celebration for the winner
// - Exclusions
//   - Temporarily exclude members for the day
//   - Exclusions reset daily
// - History
//   - Recent picks list with dates
//   - Clear recent picks with one tap
// - Polished UI
//   - Glass effect components
//   - Subtle motion and transitions
//   - Confetti animation for wins

// Modules

// This project is organized as a Swift Package with multiple targets to keep responsibilities focused and reusable.

// - WTDesignSystem
//   - Shared styles, components, and effects (e.g., glass button style, glass containers, ConfettiView)
// - WTRouter
//   - Navigation helpers
// - WTTools
//   - Shared utilities, including the `WTStorage` actor for persistence
// - WTPicker
//   - Picker feature: `PickerView`, view model, state, datasource, and models for picking logic
// - WTTeamSetup
//   - Team setup feature: `TeamSetupView`, view model, and datasource for managing members

// Architecture

// - MVVM with observable state
//   - `PickerViewModel` + `PickerViewState` drive `PickerView`
//   - `TeamSetupViewModel` + `TeamSetupViewState` drive `TeamSetupView`
// - Data access through datasources per feature
//   - `PickerDatasource` and `TeamSetupDatasource` (if present) abstract `WTStorage`
// - Persistence with `WTStorage` actor
//   - JSON-based, file-per-key storage
//   - Keys include `teamMembers`, `pickRecords`, and `dailyExclusions`
//   - Includes `clearPickRecords()` to reset recent picks

// How it works

// - Team
//   - Add members in the Team Setup screen
//   - Members are persisted and displayed as chips in the picker
// - Exclusions
//   - Tap a member chip to toggle exclusion (disabled during spinning)
//   - Exclusions are stored per day and reset automatically
// - Picking
//   - Tap “Spin!” to start a weighted random selection
//   - Weighting prefers members who haven’t presented recently
//   - Winner is shown with confetti and history is updated
// - History
//   - Shows recent picks with dates
//   - “Clear” button removes persisted pick records and refreshes UI

// Screens

// - Picker
//   - Team chips
//   - Picker card (idle, spinning, or winner display)
//   - Spin button
//   - Recent picks section with clear button
// - Team Setup
//   - Add members with quick add
//   - List and delete members
//   - Done button to dismiss

// Requirements

// - iOS 18 (or the platform version specified in Package.swift)
// - Xcode 15+ (or the specific version you’re targeting)
// - Swift 6

// Check `Package.swift` for exact platform and toolchain requirements.

// Getting Started

// 1. Clone the repository and open the workspace/project in Xcode.
// 2. Ensure the local Swift package targets are added to your app target:
//    - Products used by the app include `WTPicker` and `WTTeamSetup`.
// 3. Build and run on iOS Simulator or device.

// If you see “No such module 'WTPicker'”:
// - Make sure the package is added to the workspace/project.
// - Ensure your app target has a dependency on the `WTPicker` product (and any other needed products like `WTDesignSystem`, `WTTools`, `WTTeamSetup`).
// - Clean build folder and rebuild.

// Key Files

// - Picker
//   - `PickerView.swift`: Main UI for the picker screen
//   - `PickerViewModel.swift`: Picker logic (spin, exclusions, history updates)
//   - `PickerViewState.swift`: Observable state for the picker feature
//   - `PickerDatasource.swift`: Data access for members, exclusions, and pick history
// - Team Setup
//   - `TeamSetupView.swift`: UI for managing team members
//   - `TeamSetupViewModel.swift`: Logic for loading, adding, and deleting members
// - Shared
//   - `WTStorage.swift`: Actor-based JSON storage; includes `clearPickRecords()`
//   - `ConfettiView.swift`: Lightweight confetti animation

// Clearing Recent Picks

// - Storage API
//   - `WTStorage.clearPickRecords()` removes the persisted “pickRecords” file
// - Datasource
//   - `PickerDatasource.clearPickHistory()` delegates to storage
// - ViewModel
//   - `PickerViewModel.clearHistory()` clears and reloads history
// - UI
//   - “Clear” button in the “Recent Picks” section triggers the view model method

// Contributing

// - Fork the repo and create a feature branch
// - Keep changes modular and adhere to the existing architecture
// - Prefer Swift Concurrency and SwiftUI best practices
// - Submit a PR with a clear description of the change

// Roadmap Ideas

// - iCloud sync for team and history
// - Advanced weighting strategies and user-tunable fairness settings
// - Multiple teams / contexts
// - Widgets and Live Activities
// - visionOS support with spatial widgets

// License

// This project is licensed under the MIT License. See LICENSE for details.

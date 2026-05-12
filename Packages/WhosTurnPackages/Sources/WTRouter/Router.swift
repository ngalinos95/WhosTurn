import SwiftUI

public protocol Step: Hashable, Sendable {}

public protocol Coordinator: AnyObject {
    var routerState: RouterState? { get set }
    @MainActor func navigate(to step: any Step)
}

@Observable
public final class RouterState {
    public var navigationPath = NavigationPath()

    public init() {}

    @MainActor
    public func push<S: Step>(_ step: S) {
        navigationPath.append(step)
    }

    @MainActor
    public func pop() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }

    @MainActor
    public func popToRoot() {
        navigationPath = NavigationPath()
    }
}

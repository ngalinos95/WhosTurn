import Foundation

@Observable
public final class TeamSetupViewState {
    public var newMemberName: String = ""
    public var members: [TeamSetupMemberUIModel] = []
    public var errorMessage: String?

    public init() {}
}

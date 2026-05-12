import Foundation

public protocol TeamSetupViewModelProtocol {
    var state: TeamSetupViewState { get }
    @MainActor func loadData() async
    @MainActor func addMember() async
    @MainActor func deleteMember(at offsets: IndexSet) async
}

public final class TeamSetupViewModel: TeamSetupViewModelProtocol {
    public let state: TeamSetupViewState
    private let datasource: TeamSetupDatasourceProtocol

    public init(datasource: TeamSetupDatasourceProtocol = TeamSetupDatasource()) {
        self.state = TeamSetupViewState()
        self.datasource = datasource
    }

    @MainActor
    public func loadData() async {
        do {
            state.members = try await datasource.loadMembers()
        } catch {
            state.errorMessage = "Failed to load team members"
        }
    }

    @MainActor
    public func addMember() async {
        let name = state.newMemberName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        do {
            try await datasource.addMember(name: name)
            state.newMemberName = ""
            state.members = try await datasource.loadMembers()
        } catch {
            state.errorMessage = "Failed to add member"
        }
    }

    @MainActor
    public func deleteMember(at offsets: IndexSet) async {
        let idsToDelete = offsets.map { state.members[$0].id }

        do {
            for id in idsToDelete {
                try await datasource.deleteMember(id: id)
            }
            state.members = try await datasource.loadMembers()
        } catch {
            state.errorMessage = "Failed to delete member"
        }
    }
}

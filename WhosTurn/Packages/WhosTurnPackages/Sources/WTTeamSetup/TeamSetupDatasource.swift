import Foundation
import WTTools

public protocol TeamSetupDatasourceProtocol: Sendable {
    func loadMembers() async throws -> [TeamSetupMemberUIModel]
    func addMember(name: String) async throws
    func deleteMember(id: UUID) async throws
}

public struct TeamSetupDatasource: TeamSetupDatasourceProtocol {
    private let storage: WTStorage

    public init(storage: WTStorage = .shared) {
        self.storage = storage
    }

    public func loadMembers() async throws -> [TeamSetupMemberUIModel] {
        try await storage.loadTeamMembers()
            .sorted { $0.createdAt < $1.createdAt }
            .map { TeamSetupMemberUIModel(id: $0.id, name: $0.name) }
    }

    public func addMember(name: String) async throws {
        var members = try await storage.loadTeamMembers()
        members.append(TeamMember(name: name))
        try await storage.saveTeamMembers(members)
    }

    public func deleteMember(id: UUID) async throws {
        var members = try await storage.loadTeamMembers()
        members.removeAll { $0.id == id }
        try await storage.saveTeamMembers(members)
    }
}

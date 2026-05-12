import Foundation
import WTTools

public protocol PickerDatasourceProtocol: Sendable {
    func loadMembers() async throws -> [PickerMemberUIModel]
    func loadExcludedIds() async throws -> Set<UUID>
    func loadPickHistory() async throws -> [PickRecordUIModel]
    func savePick(memberId: UUID, memberName: String) async throws
    func saveExclusions(_ excludedIds: Set<UUID>) async throws
}

public struct PickerDatasource: PickerDatasourceProtocol {
    private let storage: WTStorage

    public init(storage: WTStorage = .shared) {
        self.storage = storage
    }

    public func loadMembers() async throws -> [PickerMemberUIModel] {
        try await storage.loadTeamMembers()
            .sorted { $0.createdAt < $1.createdAt }
            .map { PickerMemberUIModel(id: $0.id, name: $0.name) }
    }

    public func loadExcludedIds() async throws -> Set<UUID> {
        let exclusions = try await storage.loadDailyExclusions()
        return exclusions.isToday ? exclusions.excludedMemberIds : []
    }

    public func loadPickHistory() async throws -> [PickRecordUIModel] {
        try await storage.loadPickRecords()
            .sorted { $0.pickedAt > $1.pickedAt }
            .prefix(30)
            .map { PickRecordUIModel(id: $0.id, memberId: $0.memberId, memberName: $0.memberName, pickedAt: $0.pickedAt) }
    }

    public func savePick(memberId: UUID, memberName: String) async throws {
        var records = try await storage.loadPickRecords()
        records.append(PickRecord(memberId: memberId, memberName: memberName))
        try await storage.savePickRecords(records)
    }

    public func saveExclusions(_ excludedIds: Set<UUID>) async throws {
        try await storage.saveDailyExclusions(DailyExclusions(excludedMemberIds: excludedIds))
    }
}

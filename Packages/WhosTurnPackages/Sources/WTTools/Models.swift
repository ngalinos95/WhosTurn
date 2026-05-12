import Foundation

public struct TeamMember: Codable, Identifiable, Hashable, Sendable {
    public let id: UUID
    public var name: String
    public let createdAt: Date

    public init(id: UUID = UUID(), name: String, createdAt: Date = .now) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
    }
}

public struct PickRecord: Codable, Identifiable, Hashable, Sendable {
    public let id: UUID
    public let memberId: UUID
    public let memberName: String
    public let pickedAt: Date

    public init(id: UUID = UUID(), memberId: UUID, memberName: String, pickedAt: Date = .now) {
        self.id = id
        self.memberId = memberId
        self.memberName = memberName
        self.pickedAt = pickedAt
    }
}

public struct DailyExclusions: Codable, Sendable {
    public let date: Date
    public var excludedMemberIds: Set<UUID>

    public init(date: Date = .now, excludedMemberIds: Set<UUID> = []) {
        self.date = date
        self.excludedMemberIds = excludedMemberIds
    }

    public var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}

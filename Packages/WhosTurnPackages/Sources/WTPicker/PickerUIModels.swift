import Foundation

public struct PickerMemberUIModel: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public var isExcluded: Bool

    public init(id: UUID, name: String, isExcluded: Bool = false) {
        self.id = id
        self.name = name
        self.isExcluded = isExcluded
    }
}

public struct PickRecordUIModel: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let memberId: UUID
    public let memberName: String
    public let pickedAt: Date

    public init(id: UUID, memberId: UUID, memberName: String, pickedAt: Date) {
        self.id = id
        self.memberId = memberId
        self.memberName = memberName
        self.pickedAt = pickedAt
    }
}

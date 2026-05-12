import Foundation

@Observable
public final class PickerViewState {
    public var members: [PickerMemberUIModel] = []
    public var pickHistory: [PickRecordUIModel] = []
    public var highlightedMemberId: UUID?
    public var selectedMember: PickerMemberUIModel?
    public var isSpinning: Bool = false
    public var showConfetti: Bool = false
    public var errorMessage: String?

    public init() {}
}

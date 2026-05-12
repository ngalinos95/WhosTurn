import Foundation

public protocol PickerViewModelProtocol {
    var state: PickerViewState { get }
    @MainActor func loadData() async
    @MainActor func spin() async
    @MainActor func toggleExclusion(for memberId: UUID) async
    @MainActor func resetSelection()
    @MainActor func clearHistory() async
}

public final class PickerViewModel: PickerViewModelProtocol {
    public let state: PickerViewState
    private let datasource: PickerDatasourceProtocol

    public init(datasource: PickerDatasourceProtocol = PickerDatasource()) {
        self.state = PickerViewState()
        self.datasource = datasource
    }

    @MainActor
    public func loadData() async {
        do {
            let members = try await datasource.loadMembers()
            let excludedIds = try await datasource.loadExcludedIds()
            let history = try await datasource.loadPickHistory()

            state.members = members.map { member in
                var m = member
                m.isExcluded = excludedIds.contains(member.id)
                return m
            }
            state.pickHistory = history
        } catch {
            state.errorMessage = "Failed to load data"
        }
    }

    @MainActor
    public func spin() async {
        let eligible = state.members.filter { !$0.isExcluded }
        guard !eligible.isEmpty, !state.isSpinning else { return }
        guard let winner = weightedRandomPick(from: eligible) else { return }

        state.isSpinning = true
        state.selectedMember = nil
        state.showConfetti = false

        let steps = 20 + Int.random(in: 0...10)

        for i in 0..<steps {
            let baseDelay = 0.05
            let progress = Double(i) / Double(steps)
            let slowdown = pow(progress, 2.5) * 0.3
            try? await Task.sleep(for: .seconds(baseDelay + slowdown))

            state.highlightedMemberId = (i == steps - 1) ? winner.id : eligible.randomElement()?.id
        }

        try? await Task.sleep(for: .seconds(0.3))

        state.isSpinning = false
        state.selectedMember = winner
        state.showConfetti = true

        do {
            try await datasource.savePick(memberId: winner.id, memberName: winner.name)
            state.pickHistory = try await datasource.loadPickHistory()
        } catch {}

        try? await Task.sleep(for: .seconds(4))
        if state.selectedMember?.id == winner.id {
            state.showConfetti = false
        }
    }

    @MainActor
    public func toggleExclusion(for memberId: UUID) async {
        guard let index = state.members.firstIndex(where: { $0.id == memberId }) else { return }
        state.members[index].isExcluded.toggle()

        let excludedIds = Set(state.members.filter(\.isExcluded).map(\.id))
        try? await datasource.saveExclusions(excludedIds)
    }

    @MainActor
    public func resetSelection() {
        state.selectedMember = nil
        state.showConfetti = false
        state.highlightedMemberId = nil
    }

    @MainActor
    public func clearHistory() async {
        do {
            try await datasource.clearPickHistory()
            state.pickHistory = try await datasource.loadPickHistory()
        } catch {
            state.errorMessage = "Failed to clear history"
        }
    }

    private func weightedRandomPick(from members: [PickerMemberUIModel]) -> PickerMemberUIModel? {
        guard !members.isEmpty else { return nil }

        let today = Date.now
        let calendar = Calendar.current

        let weights: [(PickerMemberUIModel, Double)] = members.map { member in
            let lastPick = state.pickHistory.first { $0.memberId == member.id }
            let daysSince: Int
            if let lastPick {
                daysSince = max(
                    calendar.dateComponents([.day], from: lastPick.pickedAt, to: today).day ?? 100, 0)
            } else {
                daysSince = 100
            }
            return (member, Double(min(daysSince, 5) + 1))
        }

        let totalWeight = weights.reduce(0.0) { $0 + $1.1 }
        var random = Double.random(in: 0..<totalWeight)

        for (member, weight) in weights {
            random -= weight
            if random <= 0 { return member }
        }

        return members.last
    }
}

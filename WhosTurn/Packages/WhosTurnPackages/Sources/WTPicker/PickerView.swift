import SwiftUI
import WTDesignSystem

public struct PickerView: View {
    private let viewModel: PickerViewModelProtocol
    var state: PickerViewState
    private var onManageTeamTapped: (() -> Void)?

    public init(
        viewModel: PickerViewModelProtocol,
        onManageTeamTapped: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.state = viewModel.state
        self.onManageTeamTapped = onManageTeamTapped
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 32) {
                        if state.members.isEmpty {
                            emptyState
                        } else {
                            memberChips
                            pickerCard
                            spinButton
                            historySection
                        }
                    }
                    .padding()
                }

                ConfettiView(isActive: state.showConfetti)
                    .ignoresSafeArea()
            }
            .navigationTitle("Who's Turn?")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onManageTeamTapped?()
                    } label: {
                        Image(systemName: "person.3.fill")
                    }
                    .buttonStyle(.glass)
                }
            }
            .task {
                await viewModel.loadData()
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("No team members yet")
                .font(.title2.weight(.medium))
            Text("Add your team to get started")
                .foregroundStyle(.secondary)
            Button {
                onManageTeamTapped?()
            } label: {
                Label("Add Team", systemImage: "plus")
                    .padding(.horizontal, 8)
            }
            .buttonStyle(.glass(.regular.tint(.blue).interactive()))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    // MARK: - Member Chips

    private var memberChips: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Team")
                .font(.headline)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
//                GlassEffectContainer(spacing: 8) {
                    HStack(spacing: 10) {
                        ForEach(state.members) { member in
                            memberChip(member)
                        }
                    }
                    .padding(.vertical, 12)
//                }
            }
        }
    }

    private func memberChip(_ member: PickerMemberUIModel) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(member.isExcluded ? Color.gray.opacity(0.3) : Color.accentColor.opacity(0.3))
                .frame(width: 28, height: 28)
                .overlay {
                    Text(String(member.name.prefix(1)).uppercased())
                        .font(.caption.bold())
                        .foregroundStyle(member.isExcluded ? .secondary : .primary)
                }
            Text(member.name)
                .font(.subheadline.weight(.medium))
                .strikethrough(member.isExcluded)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .glassEffect(
            member.isExcluded
                ? .regular.tint(.gray)
                : (state.highlightedMemberId == member.id
                    ? .regular.tint(.blue).interactive()
                    : .regular.interactive())
        )
        .opacity(member.isExcluded ? 0.5 : 1.0)
        .scaleEffect(
            state.highlightedMemberId == member.id && !member.isExcluded ? 1.1 : 1.0)
        .animation(.easeOut(duration: 0.08), value: state.highlightedMemberId)
        .onTapGesture {
            guard !state.isSpinning else { return }
            Task { await viewModel.toggleExclusion(for: member.id) }
        }
    }

    // MARK: - Picker Card

    private var pickerCard: some View {
        VStack(spacing: 12) {
            if let selected = state.selectedMember {
                winnerDisplay(selected)
            } else if state.isSpinning,
                let memberId = state.highlightedMemberId,
                let member = state.members.first(where: { $0.id == memberId })
            {
                spinningDisplay(member)
            } else {
                idleDisplay
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220)
        .glassEffect(in: .rect(cornerRadius: 24))
    }

    private func winnerDisplay(_ member: PickerMemberUIModel) -> some View {
        VStack(spacing: 10) {
            Image(systemName: "crown.fill")
                .font(.system(size: 44))
                .foregroundStyle(.yellow)
                .symbolEffect(.bounce, value: state.showConfetti)
            Text(member.name)
                .font(.system(size: 38, weight: .bold, design: .rounded))
            Text("is presenting!")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .scaleEffect(state.showConfetti ? 1.05 : 0.95)
        .animation(.spring(duration: 0.6, bounce: 0.4), value: state.showConfetti)
    }

    private func spinningDisplay(_ member: PickerMemberUIModel) -> some View {
        Text(member.name)
            .font(.system(size: 38, weight: .bold, design: .rounded))
            .id(member.id)
            .transition(.push(from: .bottom).combined(with: .opacity))
            .animation(.easeOut(duration: 0.06), value: state.highlightedMemberId)
    }

    private var idleDisplay: some View {
        VStack(spacing: 10) {
            Image(systemName: "dice.fill")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text("Tap Spin to pick!")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Spin Button

    private var spinButton: some View {
        Button {
            if state.selectedMember != nil {
                viewModel.resetSelection()
            } else {
                Task { await viewModel.spin() }
            }
        } label: {
            Label(
                state.selectedMember != nil
                    ? "Spin Again"
                    : (state.isSpinning ? "Spinning..." : "Spin!"),
                systemImage: state.selectedMember != nil ? "arrow.clockwise" : "dice.fill"
            )
            .font(.title2.bold())
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(.glass(.regular.tint(.blue)))
        .disabled(state.isSpinning || state.members.filter({ !$0.isExcluded }).isEmpty)
    }

    // MARK: - History

    @ViewBuilder
    private var historySection: some View {
        if !state.pickHistory.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Recent Picks")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button(role: .destructive) {
                        Task { await viewModel.clearHistory() }
                    } label: {
                        Label("Clear", systemImage: "trash")
                    }
                    .buttonStyle(.glass(.regular.tint(.gray)))
                    .disabled(state.isSpinning || state.pickHistory.isEmpty)
                }

                VStack(spacing: 0) {
                    ForEach(Array(state.pickHistory.prefix(7).enumerated()), id: \.element.id) {
                        index, record in
                        HStack {
                            Text(record.memberName)
                                .font(.body.weight(.medium))
                            Spacer()
                            Text(
                                record.pickedAt,
                                format: .dateTime.month(.abbreviated).day()
                            )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)

                        if index < min(state.pickHistory.count, 7) - 1 {
                            Divider().padding(.horizontal, 16)
                        }
                    }
                }
                .glassEffect(in: .rect(cornerRadius: 16))
            }
        }
    }
}


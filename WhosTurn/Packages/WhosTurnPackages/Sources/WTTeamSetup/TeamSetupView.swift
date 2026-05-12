import SwiftUI

public struct TeamSetupView: View {
    private let viewModel: TeamSetupViewModelProtocol
    @Bindable var state: TeamSetupViewState
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: TeamSetupViewModelProtocol = TeamSetupViewModel()) {
        self.viewModel = viewModel
        self.state = viewModel.state
    }

    public var body: some View {
        NavigationStack {
            List {
                Section("Add Member") {
                    HStack {
                        TextField("Name", text: $state.newMemberName)
                            .textContentType(.name)
                            .submitLabel(.done)
                            .onSubmit { addMember() }
                        Button(action: addMember) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.blue)
                        }
                        .disabled(
                            state.newMemberName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }

                Section("Team (\(state.members.count))") {
                    if state.members.isEmpty {
                        ContentUnavailableView(
                            "No members",
                            systemImage: "person.slash",
                            description: Text("Add team members above")
                        )
                    } else {
                        ForEach(state.members) { member in
                            HStack {
                                Circle()
                                    .fill(Color.accentColor.opacity(0.2))
                                    .frame(width: 36, height: 36)
                                    .overlay {
                                        Text(String(member.name.prefix(1)).uppercased())
                                            .font(.callout.bold())
                                    }
                                Text(member.name)
                            }
                        }
                        .onDelete { offsets in
                            Task { await viewModel.deleteMember(at: offsets) }
                        }
                    }
                }
            }
            .navigationTitle("Manage Team")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
                if !state.members.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        EditButton()
                    }
                }
            }
            .task {
                await viewModel.loadData()
            }
        }
    }

    private func addMember() {
        Task { await viewModel.addMember() }
    }
}

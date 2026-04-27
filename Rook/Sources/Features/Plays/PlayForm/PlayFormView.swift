import SwiftUI

struct PlayFormView: View {
    @Bindable var model: PlayFormModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color.rookBackground.ignoresSafeArea()
                form
            }
            .navigationTitle("Log a play")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { model.onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { model.saveButtonTapped() }
                        .disabled(!model.canSave)
                }
            }
            .toolbarBackground(Color.rookBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private var form: some View {
        Form {
            Section("Game") {
                Picker("Game", selection: $model.play.gameID) {
                    ForEach(model.availableGames) { game in
                        Text(game.name).tag(game.id)
                    }
                }
            }
            .listRowBackground(Color.rookSurface)

            Section("Details") {
                DatePicker("Played on", selection: $model.play.playedAt)
                Stepper(value: $model.play.durationMinutes, in: 5...600, step: 5) {
                    HStack {
                        Text("Duration")
                        Spacer()
                        Text("\(model.play.durationMinutes) min")
                            .foregroundStyle(Color.rookForegroundSecondary)
                    }
                }
                TextField("Location (optional)", text: $model.play.location)
            }
            .listRowBackground(Color.rookSurface)

            Section("Players") {
                ForEach($model.play.participants) { $participant in
                    HStack(spacing: RookSpacing.s) {
                        TextField("Name", text: $participant.name)
                        TextField("Score", value: $participant.score, format: .number)
                            .keyboardType(.numberPad)
                            .frame(maxWidth: 60)
                            .multilineTextAlignment(.trailing)
                        Button {
                            model.toggleWinner(participant.id)
                        } label: {
                            Image(systemName: participant.isWinner ? "trophy.fill" : "trophy")
                                .foregroundStyle(participant.isWinner ? AnyShapeStyle(LinearGradient.rookBrand) : AnyShapeStyle(Color.rookForegroundTertiary))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .onDelete { offsets in
                    model.removeParticipant(at: offsets)
                }
                Button {
                    model.addParticipantTapped()
                } label: {
                    Label("Add player", systemImage: "plus.circle")
                }
            }
            .listRowBackground(Color.rookSurface)

            Section("Notes") {
                TextField("Optional", text: $model.play.notes, axis: .vertical)
                    .lineLimit(2...6)
            }
            .listRowBackground(Color.rookSurface)
        }
        .scrollContentBackground(.hidden)
    }
}

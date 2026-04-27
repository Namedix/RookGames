import SwiftUI
import SwiftUINavigation

struct PlayDetailView: View {
    @Bindable var model: PlayDetailModel

    var body: some View {
        ZStack {
            Color.rookBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: RookSpacing.l) {
                    header
                    if !model.play.participants.isEmpty {
                        participants
                    }
                    if !model.play.notes.isEmpty {
                        notes
                    }
                }
                .padding(.horizontal, RookSpacing.l)
                .padding(.vertical, RookSpacing.m)
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(model.game?.name ?? "Play")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        model.editButtonTapped()
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        model.deleteButtonTapped()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .toolbarBackground(Color.rookBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(item: $model.destination.edit) { formModel in
            PlayFormView(model: formModel)
        }
        .alert($model.destination.alert) { action in
            model.alertButtonTapped(action)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: RookSpacing.m) {
            Text(model.play.playedAt, format: .dateTime.weekday(.wide).month(.wide).day().year())
                .rookFont(.subheadline)
                .foregroundStyle(Color.rookForegroundSecondary)

            HStack(spacing: RookSpacing.m) {
                statChip(icon: "clock", value: "\(model.play.durationMinutes) min")
                if !model.play.location.isEmpty {
                    statChip(icon: "mappin.circle", value: model.play.location)
                }
                if let winner = model.play.winner {
                    statChip(icon: "trophy.fill", value: "Winner: \(winner.name)")
                }
            }
        }
    }

    private func statChip(icon: String, value: String) -> some View {
        HStack(spacing: RookSpacing.xs) {
            Image(systemName: icon)
            Text(value)
        }
        .rookFont(.caption)
        .foregroundStyle(Color.rookForegroundSecondary)
        .padding(.horizontal, RookSpacing.m)
        .padding(.vertical, RookSpacing.s)
        .background(Capsule().fill(Color.rookSurface))
    }

    private var participants: some View {
        VStack(alignment: .leading, spacing: RookSpacing.s) {
            Text("Players")
                .rookFont(.subheadline)
                .foregroundStyle(Color.rookForegroundSecondary)
                .textCase(.uppercase)
            VStack(spacing: 0) {
                ForEach(model.play.participants) { participant in
                    HStack {
                        if participant.isWinner {
                            Image(systemName: "trophy.fill")
                                .foregroundStyle(LinearGradient.rookBrand)
                        }
                        Text(participant.name)
                            .rookFont(.body)
                            .foregroundStyle(Color.rookForeground)
                        Spacer()
                        if let score = participant.score {
                            Text("\(score)")
                                .rookFont(.headline)
                                .monospacedDigit()
                                .foregroundStyle(Color.rookForeground)
                        }
                    }
                    .padding(.vertical, RookSpacing.s)
                    if participant.id != model.play.participants.last?.id {
                        Divider().background(Color.rookSeparator)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .rookCard()
        }
    }

    private var notes: some View {
        VStack(alignment: .leading, spacing: RookSpacing.s) {
            Text("Notes")
                .rookFont(.subheadline)
                .foregroundStyle(Color.rookForegroundSecondary)
                .textCase(.uppercase)
            Text(model.play.notes)
                .rookFont(.body)
                .foregroundStyle(Color.rookForeground)
                .frame(maxWidth: .infinity, alignment: .leading)
                .rookCard()
        }
    }
}

import Sharing
import SwiftUI
import SwiftUINavigation

struct PlaysListView: View {
    @Bindable var model: PlaysListModel

    var body: some View {
        ZStack {
            Color.rookBackground.ignoresSafeArea()

            if model.plays.isEmpty {
                emptyState
            } else {
                list
            }
        }
        .navigationTitle("Plays")
        .toolbar {
            ToolbarItem(placement: .secondaryAction) {
                Button {
                    model.statsButtonTapped()
                } label: {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                }
                .accessibilityLabel("Stats")
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    model.addPlayButtonTapped()
                } label: {
                    Image(systemName: "plus")
                        .rookFont(.headline)
                        .foregroundStyle(Color.rookForeground)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(LinearGradient.rookBrand))
                }
                .accessibilityLabel("Log play")
                .disabled(model.collection.isEmpty)
            }
        }
        .toolbarBackground(Color.rookBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(item: $model.destination.form) { formModel in
            PlayFormView(model: formModel)
        }
    }

    private var emptyState: some View {
        VStack(spacing: RookSpacing.l) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 56))
                .foregroundStyle(LinearGradient.rookBrand)
            Text("No plays logged yet")
                .rookFont(.title2)
                .foregroundStyle(Color.rookForeground)
            Text("Add your first session to start tracking stats.")
                .rookFont(.body)
                .foregroundStyle(Color.rookForegroundSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, RookSpacing.xl)
            if !model.collection.isEmpty {
                Button("Log a play") { model.addPlayButtonTapped() }
                    .buttonStyle(.rookPrimary)
                    .padding(.horizontal, RookSpacing.xl)
            } else {
                Text("Add games to your library first.")
                    .rookFont(.caption)
                    .foregroundStyle(Color.rookForegroundTertiary)
            }
        }
        .padding(RookSpacing.xl)
    }

    private var list: some View {
        ScrollView {
            LazyVStack(spacing: RookSpacing.m) {
                ForEach(model.sortedPlays) { entry in
                    Button {
                        model.playTapped(entry.play)
                    } label: {
                        PlayRow(play: entry.play.wrappedValue, game: entry.game)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            model.deletePlay(id: entry.play.wrappedValue.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.horizontal, RookSpacing.l)
            .padding(.vertical, RookSpacing.m)
        }
        .scrollContentBackground(.hidden)
    }
}

struct PlayRow: View {
    let play: Play
    let game: Game?

    var body: some View {
        HStack(spacing: RookSpacing.m) {
            VStack(alignment: .leading, spacing: RookSpacing.xs) {
                Text(game?.name ?? "Unknown game")
                    .rookFont(.headline)
                    .foregroundStyle(Color.rookForeground)
                HStack(spacing: RookSpacing.s) {
                    Text(play.playedAt, format: .dateTime.month(.abbreviated).day().year())
                    Text("·")
                    Text("\(play.durationMinutes) min")
                    if !play.participants.isEmpty {
                        Text("·")
                        Text("\(play.participants.count) players")
                    }
                }
                .rookFont(.caption)
                .foregroundStyle(Color.rookForegroundSecondary)
            }
            Spacer()
            if let winner = play.winner {
                VStack(alignment: .trailing, spacing: RookSpacing.xs) {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(LinearGradient.rookBrand)
                    Text(winner.name)
                        .rookFont(.caption)
                        .foregroundStyle(Color.rookForegroundSecondary)
                }
            }
            Image(systemName: "chevron.right")
                .rookFont(.footnote)
                .foregroundStyle(Color.rookForegroundTertiary)
        }
        .rookCard()
        .contentShape(RoundedRectangle(cornerRadius: RookRadius.l, style: .continuous))
    }
}

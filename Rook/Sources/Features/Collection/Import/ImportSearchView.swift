import SwiftUI

struct ImportSearchView: View {
    @Bindable var model: ImportSearchModel

    var body: some View {
        ZStack {
            Color.rookBackground.ignoresSafeArea()
            content
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $model.query, prompt: "Search board games")
        .task { await model.task() }
        .onChange(of: model.query) { _, _ in
            Task { await model.queryChanged() }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add (\(model.selectedIDs.count))") {
                    model.confirmButtonTapped()
                }
                .disabled(model.selectedIDs.isEmpty)
            }
        }
        .toolbarBackground(Color.rookBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    @ViewBuilder
    private var content: some View {
        if model.isLoading && model.results.isEmpty {
            ProgressView()
                .tint(.rookAccent)
        } else if let message = model.errorMessage {
            ContentUnavailableView(
                "Search failed",
                systemImage: "exclamationmark.triangle",
                description: Text(message)
            )
            .foregroundStyle(Color.rookForegroundSecondary)
        } else if model.results.isEmpty {
            ContentUnavailableView(
                "Type a name",
                systemImage: "magnifyingglass",
                description: Text("We'll suggest games as you type.")
            )
            .foregroundStyle(Color.rookForegroundSecondary)
        } else {
            List {
                ForEach(model.results) { game in
                    GameSelectionRow(
                        game: game,
                        isSelected: model.selectedIDs.contains(game.id)
                    )
                    .listRowBackground(Color.rookSurface)
                    .contentShape(Rectangle())
                    .onTapGesture { model.toggle(game) }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }
}

struct GameSelectionRow: View {
    let game: Game
    let isSelected: Bool

    var body: some View {
        HStack(spacing: RookSpacing.m) {
            VStack(alignment: .leading, spacing: RookSpacing.xs) {
                Text(game.name)
                    .rookFont(.headline)
                    .foregroundStyle(Color.rookForeground)
                Text("\(game.playerRangeText) players · \(game.playtimeText)")
                    .rookFont(.caption)
                    .foregroundStyle(Color.rookForegroundSecondary)
            }
            Spacer()
            Image(systemName: isSelected ? "checkmark.circle.fill" : "plus.circle")
                .font(.system(size: 24))
                .foregroundStyle(isSelected ? AnyShapeStyle(LinearGradient.rookBrand) : AnyShapeStyle(Color.rookForegroundTertiary))
        }
        .padding(.vertical, RookSpacing.xs)
    }
}

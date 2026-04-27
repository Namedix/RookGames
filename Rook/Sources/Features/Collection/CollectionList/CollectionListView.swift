import IdentifiedCollections
import Sharing
import SwiftUI
import SwiftUINavigation

struct CollectionListView: View {
    @Bindable var model: CollectionListModel

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: RookSpacing.m),
        GridItem(.flexible(), spacing: RookSpacing.m),
    ]

    var body: some View {
        ZStack {
            Color.rookBackground.ignoresSafeArea()

            if model.collection.isEmpty {
                emptyState
            } else {
                content
            }
        }
        .navigationTitle("Library")
        .toolbar {
            ToolbarItem(placement: .principal) {
                RookWordmark(size: .small)
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    model.addButtonTapped()
                } label: {
                    Image(systemName: "plus")
                        .rookFont(.headline)
                        .foregroundStyle(Color.rookForeground)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(LinearGradient.rookBrand))
                }
                .accessibilityLabel("Add game")
            }
            ToolbarItem(placement: .secondaryAction) {
                Menu {
                    Picker("Sort", selection: $model.sort) {
                        ForEach(CollectionListModel.Sort.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
        }
        .toolbarBackground(Color.rookBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .searchable(text: $model.searchText, prompt: "Search your library")
        .sheet(item: $model.destination.importFlow) { flow in
            ImportFlowView(model: flow)
        }
    }

    private var emptyState: some View {
        VStack(spacing: RookSpacing.l) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 56, weight: .regular))
                .foregroundStyle(LinearGradient.rookBrand)
            Text("No games yet")
                .rookFont(.title2)
                .foregroundStyle(Color.rookForeground)
            Text("Snap a photo of your shelf, scan a barcode, or search to add your first game.")
                .rookFont(.body)
                .foregroundStyle(Color.rookForegroundSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, RookSpacing.xl)
            Button("Add a game") { model.addButtonTapped() }
                .buttonStyle(.rookPrimary)
                .padding(.horizontal, RookSpacing.xl)
        }
        .padding(RookSpacing.xl)
    }

    private var content: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: RookSpacing.m) {
                ForEach(model.filteredGames) { game in
                    Button {
                        model.gameTapped(id: game.id)
                    } label: {
                        GameCard(game: game)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            model.removeGame(id: game.id)
                        } label: {
                            Label("Remove", systemImage: "trash")
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

struct GameCard: View {
    let game: Game

    var body: some View {
        VStack(alignment: .leading, spacing: RookSpacing.s) {
            RoundedRectangle(cornerRadius: RookRadius.m, style: .continuous)
                .fill(LinearGradient.rookBrand.opacity(0.18))
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    Image(systemName: "die.face.5")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundStyle(LinearGradient.rookBrand)
                }
            Text(game.name)
                .rookFont(.headline)
                .foregroundStyle(Color.rookForeground)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            HStack(spacing: RookSpacing.s) {
                Label(game.playerRangeText, systemImage: "person.2")
                Label(game.playtimeText, systemImage: "clock")
            }
            .rookFont(.caption)
            .foregroundStyle(Color.rookForegroundSecondary)
        }
        .padding(RookSpacing.m)
        .background(
            RoundedRectangle(cornerRadius: RookRadius.l, style: .continuous)
                .fill(Color.rookSurface)
        )
        .contentShape(RoundedRectangle(cornerRadius: RookRadius.l, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        CollectionListView(model: CollectionListModel())
    }
    .preferredColorScheme(.dark)
}

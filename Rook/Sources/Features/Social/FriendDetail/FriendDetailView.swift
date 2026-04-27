import SwiftUI

struct FriendDetailView: View {
    @Bindable var model: FriendDetailModel

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: RookSpacing.m),
        GridItem(.flexible(), spacing: RookSpacing.m),
    ]

    var body: some View {
        ZStack {
            Color.rookBackground.ignoresSafeArea()
            content
        }
        .navigationTitle(model.friend.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $model.searchText, prompt: "Search this library")
        .task { await model.task() }
        .toolbarBackground(Color.rookBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    @ViewBuilder
    private var content: some View {
        if model.isLoading && model.library.isEmpty {
            ProgressView().tint(.rookAccent)
        } else if let message = model.errorMessage {
            ContentUnavailableView(
                "Couldn't load library",
                systemImage: "wifi.slash",
                description: Text(message)
            )
            .foregroundStyle(Color.rookForegroundSecondary)
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: RookSpacing.m) {
                    header
                    LazyVGrid(columns: columns, spacing: RookSpacing.m) {
                        ForEach(model.filteredLibrary) { game in
                            FriendGameCard(game: game, ownedByMe: model.isOwnedByMe(game))
                        }
                    }
                }
                .padding(.horizontal, RookSpacing.l)
                .padding(.vertical, RookSpacing.m)
            }
            .scrollContentBackground(.hidden)
        }
    }

    private var header: some View {
        HStack(spacing: RookSpacing.m) {
            Circle()
                .fill(LinearGradient.rookBrand.opacity(0.25))
                .frame(width: 56, height: 56)
                .overlay {
                    Text(model.friend.displayName.prefix(1).uppercased())
                        .rookFont(.title2)
                        .foregroundStyle(LinearGradient.rookBrand)
                }
            VStack(alignment: .leading, spacing: RookSpacing.xs) {
                Text("@\(model.friend.handle)")
                    .rookFont(.subheadline)
                    .foregroundStyle(Color.rookForegroundSecondary)
                Text("\(model.library.count) games")
                    .rookFont(.headline)
                    .foregroundStyle(Color.rookForeground)
            }
            Spacer()
        }
    }
}

struct FriendGameCard: View {
    let game: Game
    let ownedByMe: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: RookSpacing.s) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: RookRadius.m, style: .continuous)
                    .fill(LinearGradient.rookBrand.opacity(0.18))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        Image(systemName: "die.face.5")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundStyle(LinearGradient.rookBrand)
                    }
                if ownedByMe {
                    Image(systemName: "checkmark.seal.fill")
                        .rookFont(.subheadline)
                        .foregroundStyle(LinearGradient.rookBrand)
                        .padding(RookSpacing.s)
                }
            }
            Text(game.name)
                .rookFont(.headline)
                .foregroundStyle(Color.rookForeground)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            Text(ownedByMe ? "You also own this" : "\(game.playerRangeText) players · \(game.playtimeText)")
                .rookFont(.caption)
                .foregroundStyle(ownedByMe ? AnyShapeStyle(LinearGradient.rookBrand) : AnyShapeStyle(Color.rookForegroundSecondary))
        }
        .padding(RookSpacing.m)
        .background(
            RoundedRectangle(cornerRadius: RookRadius.l, style: .continuous)
                .fill(Color.rookSurface)
        )
    }
}

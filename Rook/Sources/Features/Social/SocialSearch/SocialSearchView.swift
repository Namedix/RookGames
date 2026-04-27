import SwiftUI

struct SocialSearchView: View {
    @Bindable var model: SocialSearchModel

    var body: some View {
        ZStack {
            Color.rookBackground.ignoresSafeArea()
            content
        }
        .navigationTitle("Search libraries")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $model.query, prompt: "Search a game in your friends' libraries")
        .onChange(of: model.query) { _, _ in
            model.queryChanged()
        }
        .toolbarBackground(Color.rookBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    @ViewBuilder
    private var content: some View {
        if model.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            ContentUnavailableView(
                "Type a game name",
                systemImage: "magnifyingglass",
                description: Text("We'll show which friends own it.")
            )
            .foregroundStyle(Color.rookForegroundSecondary)
        } else if model.isLoading && model.results.isEmpty {
            ProgressView().tint(.rookAccent)
        } else if model.results.isEmpty {
            ContentUnavailableView(
                "No matches",
                systemImage: "questionmark.diamond",
                description: Text("None of your friends own a game like that.")
            )
            .foregroundStyle(Color.rookForegroundSecondary)
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: RookSpacing.l) {
                    ForEach(model.results, id: \.friend.id) { hit in
                        hitSection(hit)
                    }
                }
                .padding(.horizontal, RookSpacing.l)
                .padding(.vertical, RookSpacing.m)
            }
            .scrollContentBackground(.hidden)
        }
    }

    private func hitSection(_ hit: LibrarySearchHit) -> some View {
        VStack(alignment: .leading, spacing: RookSpacing.s) {
            HStack(spacing: RookSpacing.s) {
                Circle()
                    .fill(LinearGradient.rookBrand.opacity(0.25))
                    .frame(width: 32, height: 32)
                    .overlay {
                        Text(hit.friend.displayName.prefix(1).uppercased())
                            .rookFont(.subheadline)
                            .foregroundStyle(LinearGradient.rookBrand)
                    }
                Text(hit.friend.displayName)
                    .rookFont(.headline)
                    .foregroundStyle(Color.rookForeground)
                Spacer()
                Text("\(hit.matches.count) match\(hit.matches.count == 1 ? "" : "es")")
                    .rookFont(.caption)
                    .foregroundStyle(Color.rookForegroundSecondary)
            }
            VStack(spacing: 0) {
                ForEach(hit.matches) { game in
                    HStack {
                        Text(game.name)
                            .rookFont(.body)
                            .foregroundStyle(Color.rookForeground)
                        Spacer()
                        Text("\(game.playerRangeText) · \(game.playtimeText)")
                            .rookFont(.caption)
                            .foregroundStyle(Color.rookForegroundSecondary)
                    }
                    .padding(.vertical, RookSpacing.s)
                    if game.id != hit.matches.last?.id {
                        Divider().background(Color.rookSeparator)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .rookCard()
        }
    }
}

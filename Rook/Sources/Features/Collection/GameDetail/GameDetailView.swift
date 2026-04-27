import SwiftUI
import SwiftUINavigation

struct GameDetailView: View {
    @Bindable var model: GameDetailModel

    var body: some View {
        ZStack {
            Color.rookBackground.ignoresSafeArea()

            if let game = model.game {
                content(game: game)
            } else {
                ContentUnavailableView(
                    "Game removed",
                    systemImage: "questionmark.square.dashed"
                )
                .foregroundStyle(Color.rookForegroundSecondary)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(role: .destructive) {
                        model.removeButtonTapped()
                    } label: {
                        Label("Remove from library", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .toolbarBackground(Color.rookBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(item: $model.destination.rulesChat) { chatModel in
            RulesChatView(model: chatModel)
        }
        .alert($model.destination.alert) { action in
            model.alertButtonTapped(action)
        }
    }

    @ViewBuilder
    private func content(game: Game) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: RookSpacing.l) {
                hero(game: game)

                statsRow(game: game)

                actionRow

                if !game.summary.isEmpty {
                    section(title: "About") {
                        Text(game.summary)
                            .rookFont(.body)
                            .foregroundStyle(Color.rookForegroundSecondary)
                    }
                }

                tagsSection(game: game)

                playsSection
            }
            .padding(.horizontal, RookSpacing.l)
            .padding(.vertical, RookSpacing.m)
        }
        .scrollContentBackground(.hidden)
        .navigationTitle(game.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func hero(game: Game) -> some View {
        VStack(alignment: .leading, spacing: RookSpacing.m) {
            RoundedRectangle(cornerRadius: RookRadius.l, style: .continuous)
                .fill(LinearGradient.rookBrand.opacity(0.18))
                .frame(height: 200)
                .overlay {
                    Image(systemName: "die.face.5")
                        .font(.system(size: 64, weight: .semibold))
                        .foregroundStyle(LinearGradient.rookBrand)
                }

            VStack(alignment: .leading, spacing: RookSpacing.xs) {
                Text(game.name)
                    .rookFont(.title)
                    .foregroundStyle(Color.rookForeground)
                if let year = game.yearPublished {
                    Text("\(String(year))" + (game.designers.isEmpty ? "" : " · " + game.designers.joined(separator: ", ")))
                        .rookFont(.subheadline)
                        .foregroundStyle(Color.rookForegroundSecondary)
                }
            }
        }
    }

    private func statsRow(game: Game) -> some View {
        HStack(spacing: RookSpacing.m) {
            statTile(icon: "person.2", title: "Players", value: game.playerRangeText)
            statTile(icon: "clock", title: "Time", value: game.playtimeText)
            statTile(icon: "brain", title: "Weight", value: String(format: "%.1f", game.complexity))
        }
    }

    private func statTile(icon: String, title: String, value: String) -> some View {
        VStack(spacing: RookSpacing.xs) {
            Image(systemName: icon)
                .rookFont(.headline)
                .foregroundStyle(LinearGradient.rookBrand)
            Text(value)
                .rookFont(.title2)
                .foregroundStyle(Color.rookForeground)
            Text(title)
                .rookFont(.caption)
                .foregroundStyle(Color.rookForegroundSecondary)
        }
        .frame(maxWidth: .infinity)
        .rookCard(padding: RookSpacing.m, radius: RookRadius.m)
    }

    private var actionRow: some View {
        VStack(spacing: RookSpacing.s) {
            Button {
                model.openRulesChatTapped()
            } label: {
                Label("Ask the rules", systemImage: "bubble.left.and.text.bubble.right")
            }
            .buttonStyle(.rookPrimary)

            Button {
                model.showStatsTapped()
            } label: {
                Label("View stats", systemImage: "chart.line.uptrend.xyaxis")
            }
            .buttonStyle(.rookSecondary)
        }
    }

    private func tagsSection(game: Game) -> some View {
        VStack(alignment: .leading, spacing: RookSpacing.m) {
            if !game.categories.isEmpty {
                tagGroup(title: "Categories", tags: game.categories)
            }
            if !game.mechanics.isEmpty {
                tagGroup(title: "Mechanics", tags: game.mechanics)
            }
        }
    }

    private func tagGroup(title: String, tags: [String]) -> some View {
        section(title: title) {
            FlowingTags(tags: tags)
        }
    }

    private var playsSection: some View {
        section(title: "Plays") {
            VStack(alignment: .leading, spacing: RookSpacing.s) {
                HStack {
                    VStack(alignment: .leading, spacing: RookSpacing.xs) {
                        Text("\(model.totalPlays) total")
                            .rookFont(.headline)
                            .foregroundStyle(Color.rookForeground)
                        Text("Last played \(model.lastPlayedText)")
                            .rookFont(.caption)
                            .foregroundStyle(Color.rookForegroundSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rookFont(.footnote)
                        .foregroundStyle(Color.rookForegroundTertiary)
                }
                .contentShape(Rectangle())
                .onTapGesture { model.showStatsTapped() }

                ForEach(model.playsForGame.prefix(3)) { play in
                    HStack {
                        Text(play.playedAt, format: .dateTime.month(.abbreviated).day().year())
                            .rookFont(.subheadline)
                            .foregroundStyle(Color.rookForegroundSecondary)
                        Spacer()
                        if let winner = play.winner {
                            Text("Winner: \(winner.name)")
                                .rookFont(.caption)
                                .foregroundStyle(Color.rookForegroundTertiary)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func section<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: RookSpacing.s) {
            Text(title)
                .rookFont(.subheadline)
                .foregroundStyle(Color.rookForegroundSecondary)
                .textCase(.uppercase)
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
                .rookCard()
        }
    }
}

struct FlowingTags: View {
    let tags: [String]

    var body: some View {
        FlowLayout(spacing: RookSpacing.s) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .rookFont(.caption)
                    .foregroundStyle(Color.rookForeground)
                    .padding(.horizontal, RookSpacing.m)
                    .padding(.vertical, RookSpacing.xs)
                    .background(
                        Capsule().fill(Color.rookSurfaceElevated)
                    )
            }
        }
    }
}

/// Simple wrap-style flow layout.
struct FlowLayout: Layout {
    var spacing: CGFloat

    init(spacing: CGFloat = RookSpacing.s) {
        self.spacing = spacing
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        let rows = computeRows(width: width, subviews: subviews)
        let totalHeight = rows.reduce(0) { $0 + $1.height } + CGFloat(max(0, rows.count - 1)) * spacing
        return CGSize(width: width.isFinite ? width : rows.map(\.width).max() ?? 0, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(width: bounds.width, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for index in row.indices {
                let subview = subviews[index]
                let size = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += row.height + spacing
        }
    }

    private struct Row {
        var indices: [Int] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    private func computeRows(width: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = [Row()]
        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let projected = (rows[rows.count - 1].indices.isEmpty ? 0 : rows[rows.count - 1].width + spacing) + size.width
            if projected > width, !rows[rows.count - 1].indices.isEmpty {
                rows.append(Row())
            }
            var current = rows[rows.count - 1]
            if !current.indices.isEmpty { current.width += spacing }
            current.width += size.width
            current.height = max(current.height, size.height)
            current.indices.append(index)
            rows[rows.count - 1] = current
        }
        return rows
    }
}

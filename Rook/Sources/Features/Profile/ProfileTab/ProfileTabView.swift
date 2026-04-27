import SwiftUI

struct ProfileTabView: View {
    @Bindable var model: ProfileTabModel

    var body: some View {
        ZStack {
            Color.rookBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: RookSpacing.l) {
                    avatarHeader
                    statsRow
                    settingsCard
                    aboutCard
                }
                .padding(.horizontal, RookSpacing.l)
                .padding(.vertical, RookSpacing.m)
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .principal) {
                RookWordmark(size: .small)
            }
        }
        .toolbarBackground(Color.rookBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private var avatarHeader: some View {
        VStack(spacing: RookSpacing.s) {
            Circle()
                .fill(LinearGradient.rookBrand.opacity(0.25))
                .frame(width: 88, height: 88)
                .overlay {
                    Text(model.currentUser.displayName.prefix(1).uppercased())
                        .rookFont(.largeTitle)
                        .foregroundStyle(LinearGradient.rookBrand)
                }
            Text(model.currentUser.displayName)
                .rookFont(.title2)
                .foregroundStyle(Color.rookForeground)
            Text("@\(model.currentUser.handle)")
                .rookFont(.subheadline)
                .foregroundStyle(Color.rookForegroundSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, RookSpacing.l)
    }

    private var statsRow: some View {
        HStack(spacing: RookSpacing.m) {
            tile(title: "Games", value: "\(model.collectionCount)")
            tile(title: "Plays", value: "\(model.playsCount)")
            tile(title: "Friends", value: "\(model.friendsCount)")
        }
    }

    private func tile(title: String, value: String) -> some View {
        VStack(spacing: RookSpacing.xs) {
            Text(value)
                .rookFont(.title2)
                .foregroundStyle(LinearGradient.rookBrand)
            Text(title)
                .rookFont(.caption)
                .foregroundStyle(Color.rookForegroundSecondary)
        }
        .frame(maxWidth: .infinity)
        .rookCard(padding: RookSpacing.m, radius: RookRadius.m)
    }

    private var settingsCard: some View {
        VStack(spacing: 0) {
            row(icon: "bell", title: "Notifications", trailing: "Coming soon")
            divider
            row(icon: "icloud", title: "Cloud sync", trailing: "Mocked")
            divider
            row(icon: "lock.shield", title: "Privacy", trailing: nil)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .rookCard()
    }

    private var aboutCard: some View {
        VStack(spacing: 0) {
            row(icon: "info.circle", title: "About Rook", trailing: "1.0.0")
            divider
            Button {
                Task { await model.signOutButtonTapped() }
            } label: {
                row(
                    icon: "rectangle.portrait.and.arrow.right",
                    title: "Sign out",
                    trailing: model.isSigningOut ? "…" : nil,
                    tint: .red
                )
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .rookCard()
    }

    private var divider: some View {
        Divider().background(Color.rookSeparator)
    }

    private func row(
        icon: String,
        title: String,
        trailing: String?,
        tint: Color = .rookForeground
    ) -> some View {
        HStack(spacing: RookSpacing.m) {
            Image(systemName: icon)
                .rookFont(.headline)
                .foregroundStyle(tint == .red ? AnyShapeStyle(Color.red) : AnyShapeStyle(LinearGradient.rookBrand))
                .frame(width: 28)
            Text(title)
                .rookFont(.body)
                .foregroundStyle(tint == .red ? .red : Color.rookForeground)
            Spacer()
            if let trailing {
                Text(trailing)
                    .rookFont(.subheadline)
                    .foregroundStyle(Color.rookForegroundTertiary)
            }
        }
        .padding(.vertical, RookSpacing.s)
    }
}

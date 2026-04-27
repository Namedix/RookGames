import SwiftUI

struct FriendsListView: View {
    @Bindable var model: FriendsListModel

    var body: some View {
        ZStack {
            Color.rookBackground.ignoresSafeArea()

            if model.friends.isEmpty {
                emptyState
            } else {
                list
            }
        }
        .navigationTitle("Friends")
        .toolbar {
            ToolbarItem(placement: .secondaryAction) {
                Button {
                    model.searchButtonTapped()
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                .accessibilityLabel("Search libraries")
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    model.addButtonTapped()
                } label: {
                    Image(systemName: "person.badge.plus")
                        .rookFont(.headline)
                        .foregroundStyle(Color.rookForeground)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(LinearGradient.rookBrand))
                }
                .accessibilityLabel("Add friend")
            }
        }
        .toolbarBackground(Color.rookBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task { await model.task() }
        .sheet(isPresented: $model.isPresentingAdd) {
            addSheet
        }
    }

    private var emptyState: some View {
        VStack(spacing: RookSpacing.l) {
            Image(systemName: "person.2")
                .font(.system(size: 56))
                .foregroundStyle(LinearGradient.rookBrand)
            Text("No friends yet")
                .rookFont(.title2)
                .foregroundStyle(Color.rookForeground)
            Text("Add friends by handle to peek at their libraries.")
                .rookFont(.body)
                .foregroundStyle(Color.rookForegroundSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, RookSpacing.xl)
            Button("Add a friend") { model.addButtonTapped() }
                .buttonStyle(.rookPrimary)
                .padding(.horizontal, RookSpacing.xl)
        }
        .padding(RookSpacing.xl)
    }

    private var list: some View {
        ScrollView {
            VStack(spacing: RookSpacing.m) {
                searchCard
                ForEach(Array(model.friends)) { friend in
                    Button {
                        model.friendTapped(friend)
                    } label: {
                        FriendRow(friend: friend)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, RookSpacing.l)
            .padding(.vertical, RookSpacing.m)
        }
        .scrollContentBackground(.hidden)
    }

    private var searchCard: some View {
        Button {
            model.searchButtonTapped()
        } label: {
            HStack(spacing: RookSpacing.m) {
                Image(systemName: "magnifyingglass")
                    .rookFont(.headline)
                    .foregroundStyle(LinearGradient.rookBrand)
                VStack(alignment: .leading, spacing: RookSpacing.xs) {
                    Text("Search across libraries")
                        .rookFont(.headline)
                        .foregroundStyle(Color.rookForeground)
                    Text("Find a game in any of your friends' shelves.")
                        .rookFont(.caption)
                        .foregroundStyle(Color.rookForegroundSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .rookFont(.footnote)
                    .foregroundStyle(Color.rookForegroundTertiary)
            }
            .rookCard()
        }
        .buttonStyle(.plain)
    }

    private var addSheet: some View {
        NavigationStack {
            ZStack {
                Color.rookBackground.ignoresSafeArea()
                VStack(spacing: RookSpacing.l) {
                    Text("Send a friend request")
                        .rookFont(.title2)
                        .foregroundStyle(Color.rookForeground)
                    TextField("Handle", text: $model.addHandle)
                        .textFieldStyle(.plain)
                        .rookFont(.body)
                        .padding(RookSpacing.m)
                        .background(
                            RoundedRectangle(cornerRadius: RookRadius.m, style: .continuous)
                                .fill(Color.rookSurface)
                        )
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    if let message = model.errorMessage {
                        Text(message)
                            .rookFont(.caption)
                            .foregroundStyle(.red)
                    }
                    Button {
                        Task { await model.confirmAddTapped() }
                    } label: {
                        if model.isAdding {
                            ProgressView().tint(.rookForeground)
                        } else {
                            Text("Send request")
                        }
                    }
                    .buttonStyle(.rookPrimary)
                    .disabled(model.isAdding || model.addHandle.isEmpty)
                    Spacer()
                }
                .padding(RookSpacing.xl)
            }
            .navigationTitle("Add friend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { model.dismissAdd() }
                }
            }
            .toolbarBackground(Color.rookBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

struct FriendRow: View {
    let friend: Friend

    var body: some View {
        HStack(spacing: RookSpacing.m) {
            avatar
            VStack(alignment: .leading, spacing: RookSpacing.xs) {
                Text(friend.displayName)
                    .rookFont(.headline)
                    .foregroundStyle(Color.rookForeground)
                Text("@\(friend.handle) · \(friend.libraryGameIDs.count) games")
                    .rookFont(.caption)
                    .foregroundStyle(Color.rookForegroundSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .rookFont(.footnote)
                .foregroundStyle(Color.rookForegroundTertiary)
        }
        .rookCard()
        .contentShape(RoundedRectangle(cornerRadius: RookRadius.l, style: .continuous))
    }

    private var avatar: some View {
        Circle()
            .fill(LinearGradient.rookBrand.opacity(0.25))
            .frame(width: 44, height: 44)
            .overlay {
                Text(friend.displayName.prefix(1).uppercased())
                    .rookFont(.headline)
                    .foregroundStyle(LinearGradient.rookBrand)
            }
    }
}

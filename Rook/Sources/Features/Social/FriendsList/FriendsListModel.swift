import Dependencies
import IdentifiedCollections
import Sharing
import SwiftUI

@MainActor
@Observable
final class FriendsListModel {
    var isPresentingAdd = false
    var addHandle = ""
    var isAdding = false
    var errorMessage: String?

    @ObservationIgnored @Shared(.friends) var friends
    @ObservationIgnored @Dependency(\.social) var social

    var onFriendTapped: (Friend) -> Void = { _ in }
    var onSearchTapped: () -> Void = {}

    init() {}

    func task() async {
        do {
            let fresh = try await social.friends()
            $friends.withLock { $0 = IdentifiedArrayOf(uniqueElements: fresh) }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func friendTapped(_ friend: Friend) {
        onFriendTapped(friend)
    }

    func searchButtonTapped() {
        onSearchTapped()
    }

    func addButtonTapped() {
        addHandle = ""
        errorMessage = nil
        isPresentingAdd = true
    }

    func dismissAdd() {
        isPresentingAdd = false
    }

    func confirmAddTapped() async {
        let handle = addHandle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !handle.isEmpty else { return }
        isAdding = true
        defer { isAdding = false }
        do {
            try await social.sendFriendRequest(handle: handle)
            isPresentingAdd = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

extension FriendsListModel: Identifiable, Hashable {
    nonisolated var id: ObjectIdentifier { ObjectIdentifier(self) }

    nonisolated static func == (lhs: FriendsListModel, rhs: FriendsListModel) -> Bool {
        lhs === rhs
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

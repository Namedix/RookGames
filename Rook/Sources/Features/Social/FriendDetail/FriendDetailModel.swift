import Dependencies
import Sharing
import SwiftUI

@MainActor
@Observable
final class FriendDetailModel {
    let friend: Friend
    var library: [Game] = []
    var isLoading = false
    var errorMessage: String?
    var searchText = ""

    @ObservationIgnored @Shared(.collection) var myCollection
    @ObservationIgnored @Dependency(\.social) var social

    init(friend: Friend) {
        self.friend = friend
    }

    func task() async {
        isLoading = true
        defer { isLoading = false }
        do {
            library = try await social.library(friendID: friend.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    var filteredLibrary: [Game] {
        let needle = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !needle.isEmpty else { return library }
        return library.filter { $0.name.lowercased().contains(needle) }
    }

    func isOwnedByMe(_ game: Game) -> Bool {
        myCollection[id: game.id] != nil
    }
}

extension FriendDetailModel: Identifiable, Hashable {
    nonisolated var id: ObjectIdentifier { ObjectIdentifier(self) }

    nonisolated static func == (lhs: FriendDetailModel, rhs: FriendDetailModel) -> Bool {
        lhs === rhs
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

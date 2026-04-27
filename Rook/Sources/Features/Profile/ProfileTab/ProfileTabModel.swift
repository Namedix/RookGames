import Dependencies
import Sharing
import SwiftUI

@MainActor
@Observable
final class ProfileTabModel {
    @ObservationIgnored @Shared(.currentUser) var currentUser
    @ObservationIgnored @Shared(.collection) var collection
    @ObservationIgnored @Shared(.plays) var plays
    @ObservationIgnored @Shared(.friends) var friends

    @ObservationIgnored @Dependency(\.auth) var auth

    var isSigningOut = false

    init() {}

    var collectionCount: Int { collection.count }
    var playsCount: Int { plays.count }
    var friendsCount: Int { friends.count }

    func signOutButtonTapped() async {
        isSigningOut = true
        defer { isSigningOut = false }
        try? await auth.signOut()
    }
}

extension ProfileTabModel: Identifiable, Hashable {
    nonisolated var id: ObjectIdentifier { ObjectIdentifier(self) }

    nonisolated static func == (lhs: ProfileTabModel, rhs: ProfileTabModel) -> Bool {
        lhs === rhs
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

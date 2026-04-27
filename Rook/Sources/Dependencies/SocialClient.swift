import Dependencies
import DependenciesMacros
import Foundation

struct LibrarySearchHit: Equatable, Sendable {
    var friend: Friend
    var matches: [Game]
}

/// Surface for the eventual social/friends backend (Supabase or equivalent).
/// Today every endpoint is canned; the mock library catalog mirrors the
/// `Friend` mocks so feature code can drill into a friend's library.
@DependencyClient
struct SocialClient: Sendable {
    var friends: @Sendable () async throws -> [Friend]
    var friend: @Sendable (_ id: Friend.ID) async throws -> Friend
    var library: @Sendable (_ friendID: Friend.ID) async throws -> [Game]
    var searchLibraries: @Sendable (_ query: String) async throws -> [LibrarySearchHit]
    var sendFriendRequest: @Sendable (_ handle: String) async throws -> Void
}

extension SocialClient: TestDependencyKey {
    static let testValue = Self()
    static let previewValue = Self.mock
}

extension DependencyValues {
    var social: SocialClient {
        get { self[SocialClient.self] }
        set { self[SocialClient.self] = newValue }
    }
}

extension SocialClient: DependencyKey {
    static let liveValue: Self = .mock
}

extension SocialClient {
    static let mock: Self = {
        @Sendable func sleep(_ seconds: Double) async throws {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
        }

        let friendList: [Friend] = [.amelia, .david, .priya]

        let catalog: [Game.ID: Game] = Dictionary(
            uniqueKeysWithValues: [
                Game.gloomhaven, .wingspan, .azul, .spirit_island,
                .everdell, .catan, .sevenWonders, .ticketToRide,
            ].map { ($0.id, $0) }
        )

        @Sendable func games(for friend: Friend) -> [Game] {
            friend.libraryGameIDs.compactMap { catalog[$0] }
        }

        return Self(
            friends: {
                try await sleep(0.3)
                return friendList
            },
            friend: { id in
                try await sleep(0.2)
                guard let friend = friendList.first(where: { $0.id == id }) else {
                    throw SocialError.notFound
                }
                return friend
            },
            library: { id in
                try await sleep(0.25)
                guard let friend = friendList.first(where: { $0.id == id }) else {
                    throw SocialError.notFound
                }
                return games(for: friend)
            },
            searchLibraries: { query in
                try await sleep(0.4)
                let needle = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                guard !needle.isEmpty else { return [] }
                return friendList.compactMap { friend in
                    let owned = games(for: friend)
                    let matches = owned.filter { $0.name.lowercased().contains(needle) }
                    guard !matches.isEmpty else { return nil }
                    return LibrarySearchHit(friend: friend, matches: matches)
                }
            },
            sendFriendRequest: { _ in
                try await sleep(0.4)
            }
        )
    }()
}

enum SocialError: Error, Equatable {
    case notFound
    case unavailable
}

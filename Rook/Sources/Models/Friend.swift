import Foundation
import Tagged

struct Friend: Hashable, Identifiable, Codable, Sendable {
    typealias ID = Tagged<Friend, UUID>

    let id: ID
    var handle: String
    var displayName: String
    var avatarURL: URL?
    var libraryGameIDs: [Game.ID]

    init(
        id: ID,
        handle: String,
        displayName: String,
        avatarURL: URL? = nil,
        libraryGameIDs: [Game.ID] = []
    ) {
        self.id = id
        self.handle = handle
        self.displayName = displayName
        self.avatarURL = avatarURL
        self.libraryGameIDs = libraryGameIDs
    }
}

extension Friend {
    static let amelia = Self(
        id: ID(UUID(uuidString: "11111111-1111-1111-1111-111111111111")!),
        handle: "amelia",
        displayName: "Amelia",
        libraryGameIDs: [
            Game.gloomhaven.id,
            Game.spirit_island.id,
            Game.everdell.id,
        ]
    )

    static let david = Self(
        id: ID(UUID(uuidString: "22222222-2222-2222-2222-222222222222")!),
        handle: "david",
        displayName: "David",
        libraryGameIDs: [
            Game.catan.id,
            Game.sevenWonders.id,
            Game.ticketToRide.id,
            Game.azul.id,
        ]
    )

    static let priya = Self(
        id: ID(UUID(uuidString: "33333333-3333-3333-3333-333333333333")!),
        handle: "priya",
        displayName: "Priya",
        libraryGameIDs: [
            Game.wingspan.id,
            Game.everdell.id,
            Game.azul.id,
            Game.ticketToRide.id,
        ]
    )
}

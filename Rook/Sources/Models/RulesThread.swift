import Foundation
import IdentifiedCollections
import Tagged

/// A persistent chat thread of rules questions for a single game. The thread
/// id is the game id so there is at most one thread per game.
struct RulesThread: Hashable, Identifiable, Codable, Sendable {
    var gameID: Game.ID
    var messages: IdentifiedArrayOf<RulesMessage>

    var id: Game.ID { gameID }

    init(gameID: Game.ID, messages: IdentifiedArrayOf<RulesMessage> = []) {
        self.gameID = gameID
        self.messages = messages
    }
}

struct RulesMessage: Hashable, Identifiable, Codable, Sendable {
    typealias ID = Tagged<RulesMessage, UUID>

    enum Role: String, Codable, Sendable {
        case user
        case assistant
    }

    let id: ID
    var role: Role
    var text: String
    var createdAt: Date
    var isStreaming: Bool

    init(
        id: ID,
        role: Role,
        text: String,
        createdAt: Date,
        isStreaming: Bool = false
    ) {
        self.id = id
        self.role = role
        self.text = text
        self.createdAt = createdAt
        self.isStreaming = isStreaming
    }
}

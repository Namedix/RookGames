import Foundation
import IdentifiedCollections
import Tagged

struct Play: Hashable, Identifiable, Codable, Sendable {
    typealias ID = Tagged<Play, UUID>

    let id: ID
    var gameID: Game.ID
    var playedAt: Date
    var durationMinutes: Int
    var location: String
    var participants: IdentifiedArrayOf<PlayParticipant>
    var notes: String

    init(
        id: ID,
        gameID: Game.ID,
        playedAt: Date,
        durationMinutes: Int = 60,
        location: String = "",
        participants: IdentifiedArrayOf<PlayParticipant> = [],
        notes: String = ""
    ) {
        self.id = id
        self.gameID = gameID
        self.playedAt = playedAt
        self.durationMinutes = durationMinutes
        self.location = location
        self.participants = participants
        self.notes = notes
    }

    var winner: PlayParticipant? {
        participants.first(where: \.isWinner)
    }
}

struct PlayParticipant: Hashable, Identifiable, Codable, Sendable {
    typealias ID = Tagged<PlayParticipant, UUID>

    let id: ID
    var name: String
    var score: Int?
    var isWinner: Bool

    init(
        id: ID,
        name: String,
        score: Int? = nil,
        isWinner: Bool = false
    ) {
        self.id = id
        self.name = name
        self.score = score
        self.isWinner = isWinner
    }
}

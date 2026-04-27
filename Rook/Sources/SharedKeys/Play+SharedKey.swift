import Foundation
import IdentifiedCollections
import IssueReporting
import Sharing

extension SharedReaderKey
where Self == FileStorageKey<IdentifiedArrayOf<Play>>.Default {
    /// Logged plays. Persisted to disk; empty by default.
    static var plays: Self {
        Self[
            .fileStorage(URL.documentsDirectory.appending(component: "plays.json")),
            default: isTesting || ProcessInfo.processInfo.environment["UI_TEST_NAME"] != nil
                ? []
                : Play.seedPlays
        ]
    }
}

extension Play {
    /// A handful of seeded plays so Stats has something to render on first launch.
    static var seedPlays: IdentifiedArrayOf<Play> {
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        func ago(_ days: Int) -> Date {
            calendar.date(byAdding: .day, value: -days, to: now) ?? now
        }

        return [
            Play(
                id: ID(UUID(uuidString: "AAAA0001-0000-0000-0000-000000000001")!),
                gameID: Game.wingspan.id,
                playedAt: ago(2),
                durationMinutes: 65,
                location: "Living room",
                participants: [
                    PlayParticipant(
                        id: PlayParticipant.ID(UUID(uuidString: "AAAA0001-0001-0000-0000-000000000001")!),
                        name: "You",
                        score: 92,
                        isWinner: true
                    ),
                    PlayParticipant(
                        id: PlayParticipant.ID(UUID(uuidString: "AAAA0001-0002-0000-0000-000000000001")!),
                        name: "Amelia",
                        score: 81,
                        isWinner: false
                    ),
                ],
                notes: "Great food chain combo on round 3."
            ),
            Play(
                id: ID(UUID(uuidString: "AAAA0002-0000-0000-0000-000000000002")!),
                gameID: Game.azul.id,
                playedAt: ago(7),
                durationMinutes: 35,
                location: "Cafe",
                participants: [
                    PlayParticipant(
                        id: PlayParticipant.ID(UUID(uuidString: "AAAA0002-0001-0000-0000-000000000002")!),
                        name: "You",
                        score: 54,
                        isWinner: false
                    ),
                    PlayParticipant(
                        id: PlayParticipant.ID(UUID(uuidString: "AAAA0002-0002-0000-0000-000000000002")!),
                        name: "David",
                        score: 71,
                        isWinner: true
                    ),
                ]
            ),
            Play(
                id: ID(UUID(uuidString: "AAAA0003-0000-0000-0000-000000000003")!),
                gameID: Game.gloomhaven.id,
                playedAt: ago(14),
                durationMinutes: 110,
                location: "Home",
                participants: [
                    PlayParticipant(
                        id: PlayParticipant.ID(UUID(uuidString: "AAAA0003-0001-0000-0000-000000000003")!),
                        name: "You",
                        isWinner: true
                    ),
                    PlayParticipant(
                        id: PlayParticipant.ID(UUID(uuidString: "AAAA0003-0002-0000-0000-000000000003")!),
                        name: "Priya",
                        isWinner: true
                    ),
                ],
                notes: "Cleared scenario 14."
            ),
            Play(
                id: ID(UUID(uuidString: "AAAA0004-0000-0000-0000-000000000004")!),
                gameID: Game.wingspan.id,
                playedAt: ago(28),
                durationMinutes: 70,
                participants: [
                    PlayParticipant(
                        id: PlayParticipant.ID(UUID(uuidString: "AAAA0004-0001-0000-0000-000000000004")!),
                        name: "You",
                        score: 88,
                        isWinner: false
                    ),
                    PlayParticipant(
                        id: PlayParticipant.ID(UUID(uuidString: "AAAA0004-0002-0000-0000-000000000004")!),
                        name: "Amelia",
                        score: 99,
                        isWinner: true
                    ),
                ]
            ),
        ]
    }
}

import Dependencies
import Sharing
import SwiftUI

@MainActor
@Observable
final class GameStatsModel {
    let gameID: Game.ID

    @ObservationIgnored @Shared(.collection) var collection
    @ObservationIgnored @Shared(.plays) var plays

    init(gameID: Game.ID) {
        self.gameID = gameID
    }

    var game: Game? { collection[id: gameID] }

    var gamePlays: [Play] {
        plays.filter { $0.gameID == gameID }
    }

    var totalPlays: Int { gamePlays.count }

    var totalMinutes: Int {
        gamePlays.reduce(0) { $0 + $1.durationMinutes }
    }

    var averageMinutes: Int {
        guard !gamePlays.isEmpty else { return 0 }
        return totalMinutes / gamePlays.count
    }

    var winRate: Double? {
        let withWinner = gamePlays.filter { $0.winner != nil }
        guard !withWinner.isEmpty else { return nil }
        let youWins = withWinner.filter { $0.winner?.name.lowercased() == "you" }.count
        return Double(youWins) / Double(withWinner.count)
    }

    /// Last 12 months bucketed by calendar month.
    var monthlyPlays: [MonthlyBucket] {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        guard let start = calendar.date(byAdding: .month, value: -11, to: now) else { return [] }
        let startOfMonth = calendar.dateInterval(of: .month, for: start)?.start ?? start

        var buckets: [Date: Int] = [:]
        for offset in 0..<12 {
            if let date = calendar.date(byAdding: .month, value: offset, to: startOfMonth),
               let bucket = calendar.dateInterval(of: .month, for: date)?.start {
                buckets[bucket] = 0
            }
        }
        for play in gamePlays {
            guard let bucket = calendar.dateInterval(of: .month, for: play.playedAt)?.start,
                  buckets[bucket] != nil else { continue }
            buckets[bucket, default: 0] += 1
        }
        return buckets
            .map { MonthlyBucket(month: $0.key, count: $0.value) }
            .sorted { $0.month < $1.month }
    }

    var highestScore: Int? {
        gamePlays.flatMap(\.participants).compactMap(\.score).max()
    }
}

extension GameStatsModel: Identifiable, Hashable {
    nonisolated var id: ObjectIdentifier { ObjectIdentifier(self) }

    nonisolated static func == (lhs: GameStatsModel, rhs: GameStatsModel) -> Bool {
        lhs === rhs
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

struct MonthlyBucket: Hashable, Identifiable {
    var month: Date
    var count: Int
    var id: Date { month }
}

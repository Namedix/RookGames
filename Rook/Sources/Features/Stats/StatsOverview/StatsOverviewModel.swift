import Dependencies
import Sharing
import SwiftUI

@MainActor
@Observable
final class StatsOverviewModel {
    enum Period: String, CaseIterable, Hashable {
        case week = "7 days"
        case month = "30 days"
        case quarter = "90 days"
        case year = "365 days"

        var days: Int {
            switch self {
            case .week: 7
            case .month: 30
            case .quarter: 90
            case .year: 365
            }
        }
    }

    var period: Period = .month

    @ObservationIgnored @Shared(.plays) var plays
    @ObservationIgnored @Shared(.collection) var collection

    @ObservationIgnored @Dependency(\.date.now) var now

    init() {}

    var periodPlays: [Play] {
        let cutoff = now.addingTimeInterval(-Double(period.days * 24 * 3600))
        return plays.filter { $0.playedAt >= cutoff }
    }

    var totalPlays: Int { periodPlays.count }

    var totalMinutes: Int {
        periodPlays.reduce(0) { $0 + $1.durationMinutes }
    }

    var uniqueGames: Int {
        Set(periodPlays.map(\.gameID)).count
    }

    var allTimePlays: Int { plays.count }

    /// Top 5 games by play count in the selected period.
    var topGames: [(game: Game, count: Int)] {
        var counts: [Game.ID: Int] = [:]
        for play in periodPlays {
            counts[play.gameID, default: 0] += 1
        }
        return counts
            .compactMap { id, count -> (Game, Int)? in
                guard let game = collection[id: id] else { return nil }
                return (game, count)
            }
            .sorted { $0.1 > $1.1 }
            .prefix(5)
            .map { (game: $0.0, count: $0.1) }
    }

    /// Buckets the period into evenly spaced calendar days for charting.
    var dailyBuckets: [DayBucket] {
        let calendar = Calendar(identifier: .gregorian)
        let endDay = calendar.startOfDay(for: now)
        guard let startDay = calendar.date(byAdding: .day, value: -(period.days - 1), to: endDay) else {
            return []
        }

        var buckets: [Date: Int] = [:]
        for offset in 0..<period.days {
            if let day = calendar.date(byAdding: .day, value: offset, to: startDay) {
                buckets[day] = 0
            }
        }
        for play in periodPlays {
            let day = calendar.startOfDay(for: play.playedAt)
            if buckets[day] != nil {
                buckets[day, default: 0] += 1
            }
        }
        return buckets
            .map { DayBucket(day: $0.key, count: $0.value) }
            .sorted { $0.day < $1.day }
    }
}

extension StatsOverviewModel: Identifiable, Hashable {
    nonisolated var id: ObjectIdentifier { ObjectIdentifier(self) }

    nonisolated static func == (lhs: StatsOverviewModel, rhs: StatsOverviewModel) -> Bool {
        lhs === rhs
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

struct DayBucket: Hashable, Identifiable {
    var day: Date
    var count: Int
    var id: Date { day }
}

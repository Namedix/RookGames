import Dependencies
import IdentifiedCollections
import Sharing
import SwiftUI

@MainActor
@Observable
final class PlayFormModel {
    var play: Play

    @ObservationIgnored @Shared(.collection) var collection
    @ObservationIgnored @Dependency(\.uuid) var uuid

    var onCancel: () -> Void = {}
    var onSave: (Play) -> Void = { _ in }

    init(play: Play) {
        self.play = play
    }

    var availableGames: [Game] {
        Array(collection).sorted { $0.name < $1.name }
    }

    func addParticipantTapped() {
        play.participants.append(
            PlayParticipant(
                id: PlayParticipant.ID(uuid()),
                name: "",
                score: nil,
                isWinner: false
            )
        )
    }

    func removeParticipant(at offsets: IndexSet) {
        play.participants.remove(atOffsets: offsets)
    }

    func toggleWinner(_ id: PlayParticipant.ID) {
        guard var participant = play.participants[id: id] else { return }
        participant.isWinner.toggle()
        play.participants[id: id] = participant
    }

    func saveButtonTapped() {
        var sanitized = play
        sanitized.notes = sanitized.notes.trimmingCharacters(in: .whitespacesAndNewlines)
        sanitized.location = sanitized.location.trimmingCharacters(in: .whitespacesAndNewlines)
        sanitized.participants = IdentifiedArrayOf(uniqueElements:
            sanitized.participants
                .map { participant in
                    var p = participant
                    p.name = p.name.trimmingCharacters(in: .whitespacesAndNewlines)
                    return p
                }
                .filter { !$0.name.isEmpty }
        )
        onSave(sanitized)
    }

    var canSave: Bool {
        collection[id: play.gameID] != nil && play.durationMinutes > 0
    }
}

extension PlayFormModel: Identifiable, Hashable {
    nonisolated var id: ObjectIdentifier { ObjectIdentifier(self) }

    nonisolated static func == (lhs: PlayFormModel, rhs: PlayFormModel) -> Bool {
        lhs === rhs
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

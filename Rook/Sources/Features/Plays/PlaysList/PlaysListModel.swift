import CasePaths
import Dependencies
import IdentifiedCollections
import Sharing
import SwiftUI
import SwiftUINavigation

@MainActor
@Observable
final class PlaysListModel {
    var destination: Destination?

    @ObservationIgnored @Shared(.plays) var plays
    @ObservationIgnored @Shared(.collection) var collection

    @ObservationIgnored @Dependency(\.uuid) var uuid
    @ObservationIgnored @Dependency(\.date.now) var now

    var onPlayTapped: (Shared<Play>) -> Void = { _ in }
    var onStatsTapped: () -> Void = {}

    @CasePathable
    @dynamicMemberLookup
    enum Destination {
        case form(PlayFormModel)
    }

    init(destination: Destination? = nil) {
        self.destination = destination
    }

    struct PlayEntry: Identifiable {
        var play: Shared<Play>
        var game: Game?
        var id: Play.ID { play.wrappedValue.id }
    }

    var sortedPlays: [PlayEntry] {
        Array($plays)
            .sorted { $0.wrappedValue.playedAt > $1.wrappedValue.playedAt }
            .map { PlayEntry(play: $0, game: collection[id: $0.wrappedValue.gameID]) }
    }

    func addPlayButtonTapped() {
        startNewPlay(gameID: nil)
    }

    /// Used by cross-tab wiring (`AppModel`) when the user taps "Log a play"
    /// from a game detail screen — pre-selects that game.
    func startNewPlay(gameID: Game.ID?) {
        let form = withDependencies(from: self) {
            PlayFormModel(
                play: Play(
                    id: Play.ID(uuid()),
                    gameID: gameID ?? collection.first?.id ?? Game.ID(0),
                    playedAt: now
                )
            )
        }
        form.onCancel = { [weak self] in
            self?.destination = nil
        }
        form.onSave = { [weak self] play in
            guard let self else { return }
            $plays.withLock { $0.append(play) }
            destination = nil
        }
        destination = .form(form)
    }

    func dismissForm() {
        destination = nil
    }

    func statsButtonTapped() {
        onStatsTapped()
    }

    func playTapped(_ play: Shared<Play>) {
        onPlayTapped(play)
    }

    func deletePlay(id: Play.ID) {
        $plays.withLock { $0.remove(id: id) }
    }
}

extension PlaysListModel: Identifiable, Hashable {
    nonisolated var id: ObjectIdentifier { ObjectIdentifier(self) }

    nonisolated static func == (lhs: PlaysListModel, rhs: PlaysListModel) -> Bool {
        lhs === rhs
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

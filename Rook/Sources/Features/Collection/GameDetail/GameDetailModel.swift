import CasePaths
import Dependencies
import IdentifiedCollections
import Sharing
import SwiftUI
import SwiftUINavigation

@MainActor
@Observable
final class GameDetailModel {
    let gameID: Game.ID

    var destination: Destination?

    @ObservationIgnored @Shared(.collection) var collection
    @ObservationIgnored @Shared(.plays) var plays
    @ObservationIgnored @Dependency(\.uuid) var uuid

    var onShowStatsTapped: (Game.ID) -> Void = { _ in }
    var onGameRemoved: (Game.ID) -> Void = { _ in }

    @CasePathable
    @dynamicMemberLookup
    enum Destination {
        case rulesChat(RulesChatModel)
        case alert(AlertState<AlertAction>)
    }

    enum AlertAction {
        case confirmRemoval
    }

    init(gameID: Game.ID, destination: Destination? = nil) {
        self.gameID = gameID
        self.destination = destination
    }

    var game: Game? { collection[id: gameID] }

    var playsForGame: [Play] {
        plays
            .filter { $0.gameID == gameID }
            .sorted { $0.playedAt > $1.playedAt }
    }

    var lastPlayedText: String {
        guard let last = playsForGame.first else { return "Never played" }
        return last.playedAt.formatted(.relative(presentation: .named))
    }

    var totalPlays: Int { playsForGame.count }

    func openRulesChatTapped() {
        let chat = withDependencies(from: self) {
            RulesChatModel(gameID: gameID)
        }
        chat.onClose = { [weak self] in
            self?.destination = nil
        }
        destination = .rulesChat(chat)
    }

    func dismissRulesChat() {
        destination = nil
    }

    func showStatsTapped() {
        onShowStatsTapped(gameID)
    }

    func removeButtonTapped() {
        destination = .alert(.removeGame)
    }

    func alertButtonTapped(_ action: AlertAction?) {
        switch action {
        case .confirmRemoval:
            onGameRemoved(gameID)
        case .none:
            break
        }
    }
}

extension GameDetailModel: Identifiable, Hashable {
    nonisolated var id: ObjectIdentifier { ObjectIdentifier(self) }

    nonisolated static func == (lhs: GameDetailModel, rhs: GameDetailModel) -> Bool {
        lhs === rhs
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension AlertState where Action == GameDetailModel.AlertAction {
    static let removeGame = Self {
        TextState("Remove from library?")
    } actions: {
        ButtonState(role: .destructive, action: .confirmRemoval) {
            TextState("Remove")
        }
        ButtonState(role: .cancel) {
            TextState("Cancel")
        }
    } message: {
        TextState("This won't delete any plays you've logged for this game.")
    }
}

import CasePaths
import Dependencies
import Sharing
import SwiftUI
import SwiftUINavigation

@MainActor
@Observable
final class PlayDetailModel {
    var destination: Destination?

    @ObservationIgnored @Shared var play: Play
    @ObservationIgnored @Shared(.collection) var collection

    var onPlayDeleted: (Play.ID) -> Void = { _ in }

    @CasePathable
    @dynamicMemberLookup
    enum Destination {
        case edit(PlayFormModel)
        case alert(AlertState<AlertAction>)
    }

    enum AlertAction {
        case confirmDeletion
    }

    init(play: Shared<Play>) {
        self._play = play
    }

    var game: Game? { collection[id: play.gameID] }

    func editButtonTapped() {
        let form = withDependencies(from: self) {
            PlayFormModel(play: play)
        }
        form.onCancel = { [weak self] in
            self?.destination = nil
        }
        form.onSave = { [weak self] updated in
            guard let self else { return }
            $play.withLock { current in
                current = updated
            }
            destination = nil
        }
        destination = .edit(form)
    }

    func deleteButtonTapped() {
        destination = .alert(.deletePlay)
    }

    func alertButtonTapped(_ action: AlertAction?) {
        switch action {
        case .confirmDeletion:
            onPlayDeleted(play.id)
        case .none:
            break
        }
    }
}

extension PlayDetailModel: Identifiable, Hashable {
    nonisolated var id: ObjectIdentifier { ObjectIdentifier(self) }

    nonisolated static func == (lhs: PlayDetailModel, rhs: PlayDetailModel) -> Bool {
        lhs === rhs
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension AlertState where Action == PlayDetailModel.AlertAction {
    static let deletePlay = Self {
        TextState("Delete this play?")
    } actions: {
        ButtonState(role: .destructive, action: .confirmDeletion) {
            TextState("Delete")
        }
        ButtonState(role: .cancel) {
            TextState("Cancel")
        }
    } message: {
        TextState("This can't be undone.")
    }
}

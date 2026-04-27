import CasePaths
import Dependencies
import SwiftUI

@MainActor
@Observable
final class CollectionTabModel {
    var path: [Path] {
        didSet { bind() }
    }
    var list: CollectionListModel {
        didSet { bind() }
    }

    @CasePathable
    @dynamicMemberLookup
    enum Path: Hashable {
        case gameDetail(GameDetailModel)
        case gameStats(GameStatsModel)
    }

    init(
        path: [Path] = [],
        list: CollectionListModel = CollectionListModel()
    ) {
        self.path = path
        self.list = list
        self.bind()
    }

    private func bind() {
        list.onGameTapped = { [weak self] gameID in
            guard let self else { return }
            path.append(.gameDetail(GameDetailModel(gameID: gameID)))
        }

        for destination in path {
            switch destination {
            case let .gameDetail(model):
                bindGameDetail(model)
            case .gameStats:
                break
            }
        }
    }

    private func bindGameDetail(_ model: GameDetailModel) {
        model.onShowStatsTapped = { [weak self] gameID in
            guard let self else { return }
            path.append(.gameStats(GameStatsModel(gameID: gameID)))
        }

        model.onGameRemoved = { [weak self] gameID in
            guard let self else { return }
            list.removeGame(id: gameID)
            _ = path.popLast()
        }
    }
}

extension CollectionTabModel: Identifiable, Hashable {
    nonisolated var id: ObjectIdentifier { ObjectIdentifier(self) }

    nonisolated static func == (lhs: CollectionTabModel, rhs: CollectionTabModel) -> Bool {
        lhs === rhs
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

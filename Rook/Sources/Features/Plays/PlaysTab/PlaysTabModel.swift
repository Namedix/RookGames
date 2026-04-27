import CasePaths
import Dependencies
import SwiftUI

@MainActor
@Observable
final class PlaysTabModel {
    var path: [Path] {
        didSet { bind() }
    }
    var list: PlaysListModel {
        didSet { bind() }
    }

    @CasePathable
    @dynamicMemberLookup
    enum Path: Hashable {
        case playDetail(PlayDetailModel)
        case statsOverview(StatsOverviewModel)
    }

    init(
        path: [Path] = [],
        list: PlaysListModel = PlaysListModel()
    ) {
        self.path = path
        self.list = list
        self.bind()
    }

    private func bind() {
        list.onPlayTapped = { [weak self] sharedPlay in
            guard let self else { return }
            path.append(.playDetail(PlayDetailModel(play: sharedPlay)))
        }
        list.onStatsTapped = { [weak self] in
            guard let self else { return }
            path.append(.statsOverview(StatsOverviewModel()))
        }

        for destination in path {
            switch destination {
            case let .playDetail(model):
                bindPlayDetail(model)
            case .statsOverview:
                break
            }
        }
    }

    private func bindPlayDetail(_ model: PlayDetailModel) {
        model.onPlayDeleted = { [weak self] id in
            guard let self else { return }
            list.deletePlay(id: id)
            _ = path.popLast()
        }
    }
}

extension PlaysTabModel: Identifiable, Hashable {
    nonisolated var id: ObjectIdentifier { ObjectIdentifier(self) }

    nonisolated static func == (lhs: PlaysTabModel, rhs: PlaysTabModel) -> Bool {
        lhs === rhs
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

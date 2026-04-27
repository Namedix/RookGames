import CasePaths
import Dependencies
import SwiftUI

@MainActor
@Observable
final class AppModel {
    var path: [Path] {
        didSet { bind() }
    }
    var countersList: CountersListModel {
        didSet { bind() }
    }

    @ObservationIgnored @Dependency(\.continuousClock) var clock
    @ObservationIgnored @Dependency(\.date.now) var now
    @ObservationIgnored @Dependency(\.uuid) var uuid

    @CasePathable
    @dynamicMemberLookup
    enum Path: Hashable {
        case detail(CounterDetailModel)
    }

    init(
        path: [Path] = [],
        countersList: CountersListModel = CountersListModel()
    ) {
        self.path = path
        self.countersList = countersList
        self.bind()
    }

    /// Wire parent-owned navigation effects onto child models that exist in the
    /// path. Following SyncUps' pattern, child models expose closure hooks
    /// (e.g. `onCounterDeleted`) that the parent fills in here.
    private func bind() {
        for destination in path {
            switch destination {
            case let .detail(detailModel):
                bindDetail(model: detailModel)
            }
        }
    }

    private func bindDetail(model: CounterDetailModel) {
        model.onCounterDeleted = { [weak self] id in
            guard let self else { return }
            countersList.deleteCounter(id: id)
            _ = path.popLast()
        }
    }
}

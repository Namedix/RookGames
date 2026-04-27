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

    /// Wires child models to parent-owned navigation effects.
    /// Following SyncUps' pattern, child models expose closure hooks
    /// (e.g. `onConfirmDeletion`) that the parent fills in here.
    private func bind() {
        countersList.onCounterTapped = { [weak self] counter in
            guard let self else { return }
            withDependencies(from: self) {
                let detail = CounterDetailModel(counter: counter)
                detail.onCounterDeleted = { [weak self] id in
                    guard let self else { return }
                    countersList.deleteCounter(id: id)
                    _ = path.popLast()
                }
                path.append(.detail(detail))
            }
        }

        for destination in path {
            switch destination {
            case .detail:
                break
            }
        }
    }
}

import Dependencies
import IdentifiedCollections
import Sharing
import SwiftUI

@MainActor
@Observable
final class CountersListModel {
    var addCounter: CounterFormModel?

    @ObservationIgnored @Shared(.counters) var counters

    @ObservationIgnored @Dependency(\.uuid) var uuid

    /// Parent-owned hook. The `AppModel` fills this in to push a detail screen
    /// onto the navigation stack — keeping navigation state-driven.
    var onCounterTapped: (Shared<Counter>) -> Void = { _ in }

    init(addCounter: CounterFormModel? = nil) {
        self.addCounter = addCounter
    }

    func addCounterButtonTapped() {
        addCounter = withDependencies(from: self) {
            CounterFormModel(counter: Counter(id: Counter.ID(uuid())))
        }
    }

    func dismissAddCounterButtonTapped() {
        addCounter = nil
    }

    func confirmAddCounterButtonTapped() {
        defer { addCounter = nil }

        guard let form = addCounter else { return }
        var counter = form.counter
        counter.name = counter.name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !counter.name.isEmpty else { return }

        $counters.withLock { $0.append(counter) }
    }

    func deleteCounters(at offsets: IndexSet) {
        $counters.withLock { $0.remove(atOffsets: offsets) }
    }

    func deleteCounter(id: Counter.ID) {
        $counters.withLock { $0.remove(id: id) }
    }
}

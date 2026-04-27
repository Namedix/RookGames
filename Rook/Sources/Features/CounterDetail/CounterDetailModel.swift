import CasePaths
import Dependencies
import Sharing
import SwiftUI
import SwiftUINavigation

@MainActor
@Observable
final class CounterDetailModel {
    var destination: Destination?

    @ObservationIgnored @Shared var counter: Counter

    @ObservationIgnored @Dependency(\.uuid) var uuid

    /// Parent-owned hook. The `AppModel` fills this in to pop the stack and
    /// remove the counter from storage when the user confirms deletion.
    var onCounterDeleted: (Counter.ID) -> Void = { _ in }

    @CasePathable
    @dynamicMemberLookup
    enum Destination {
        case alert(AlertState<AlertAction>)
        case edit(CounterFormModel)
    }

    enum AlertAction {
        case confirmDeletion
    }

    init(
        destination: Destination? = nil,
        counter: Shared<Counter>
    ) {
        self.destination = destination
        self._counter = counter
    }

    func incrementButtonTapped() {
        $counter.withLock { $0.value += 1 }
    }

    func decrementButtonTapped() {
        $counter.withLock { $0.value -= 1 }
    }

    func resetButtonTapped() {
        $counter.withLock { $0.value = 0 }
    }

    func editButtonTapped() {
        destination = .edit(CounterFormModel(counter: counter, focus: .name))
    }

    func cancelEditButtonTapped() {
        destination = nil
    }

    func doneEditingButtonTapped() {
        guard case let .edit(form) = destination else { return }
        $counter.withLock {
            $0.name = form.counter.name.trimmingCharacters(in: .whitespacesAndNewlines)
            $0.value = form.counter.value
        }
        destination = nil
    }

    func deleteButtonTapped() {
        destination = .alert(.deleteCounter)
    }

    func alertButtonTapped(_ action: AlertAction?) {
        switch action {
        case .confirmDeletion:
            onCounterDeleted(counter.id)
        case .none:
            break
        }
    }
}

extension CounterDetailModel: Identifiable, Hashable {
    nonisolated var id: ObjectIdentifier { ObjectIdentifier(self) }

    nonisolated static func == (lhs: CounterDetailModel, rhs: CounterDetailModel) -> Bool {
        lhs === rhs
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension AlertState where Action == CounterDetailModel.AlertAction {
    static let deleteCounter = Self {
        TextState("Delete counter?")
    } actions: {
        ButtonState(role: .destructive, action: .confirmDeletion) {
            TextState("Delete")
        }
        ButtonState(role: .cancel) {
            TextState("Cancel")
        }
    } message: {
        TextState("This will remove the counter and all of its history.")
    }
}

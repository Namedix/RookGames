import Foundation
import SwiftUI

@MainActor
@Observable
final class CounterFormModel {
    var counter: Counter
    var focus: Field?

    enum Field: Hashable {
        case name
    }

    init(
        counter: Counter,
        focus: Field? = .name
    ) {
        self.counter = counter
        self.focus = focus
    }
}

extension CounterFormModel: Identifiable, Hashable {
    nonisolated var id: ObjectIdentifier { ObjectIdentifier(self) }

    nonisolated static func == (lhs: CounterFormModel, rhs: CounterFormModel) -> Bool {
        lhs === rhs
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

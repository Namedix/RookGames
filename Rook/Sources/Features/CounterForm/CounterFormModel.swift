import Foundation
import SwiftUI

@MainActor
@Observable
final class CounterFormModel: Identifiable {
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

extension CounterFormModel: Hashable {
    nonisolated static func == (lhs: CounterFormModel, rhs: CounterFormModel) -> Bool {
        lhs === rhs
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

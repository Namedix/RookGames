import Foundation
import IdentifiedCollections
import IssueReporting
import Sharing

extension SharedReaderKey
where Self == FileStorageKey<IdentifiedArrayOf<Counter>>.Default {
    /// Persists the user's counters to the documents directory as JSON.
    /// In tests and UI tests we boot with an empty list to keep state hermetic.
    static var counters: Self {
        Self[
            .fileStorage(URL.documentsDirectory.appending(component: "counters.json")),
            default: isTesting || ProcessInfo.processInfo.environment["UI_TEST_NAME"] != nil
                ? []
                : [.mock, .booksReadMock, .coffeeMock]
        ]
    }
}

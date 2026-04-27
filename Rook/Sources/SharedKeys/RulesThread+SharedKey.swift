import Foundation
import IdentifiedCollections
import IssueReporting
import Sharing

extension SharedReaderKey
where Self == FileStorageKey<IdentifiedArrayOf<RulesThread>>.Default {
    /// Persistent per-game rules-chat threads. Threads are appended lazily —
    /// one per game the user has asked about — so the default is empty.
    static var rulesThreads: Self {
        Self[
            .fileStorage(URL.documentsDirectory.appending(component: "rulesThreads.json")),
            default: []
        ]
    }
}

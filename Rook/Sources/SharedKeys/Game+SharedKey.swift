import Foundation
import IdentifiedCollections
import IssueReporting
import Sharing

extension SharedReaderKey
where Self == FileStorageKey<IdentifiedArrayOf<Game>>.Default {
    /// The user's owned game collection. Persisted to disk; pre-seeded with a
    /// few mocks so a fresh install has something to render.
    static var collection: Self {
        Self[
            .fileStorage(URL.documentsDirectory.appending(component: "collection.json")),
            default: isTesting || ProcessInfo.processInfo.environment["UI_TEST_NAME"] != nil
                ? []
                : [.gloomhaven, .wingspan, .azul]
        ]
    }
}

import Foundation
import IdentifiedCollections
import IssueReporting
import Sharing

extension SharedReaderKey
where Self == FileStorageKey<IdentifiedArrayOf<Friend>>.Default {
    /// Cached list of friends. Acts as instant-render data while the
    /// `SocialClient` refreshes from the (eventual) backend.
    static var friends: Self {
        Self[
            .fileStorage(URL.documentsDirectory.appending(component: "friends.json")),
            default: isTesting || ProcessInfo.processInfo.environment["UI_TEST_NAME"] != nil
                ? []
                : [.amelia, .david, .priya]
        ]
    }
}

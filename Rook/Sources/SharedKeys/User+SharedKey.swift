import Foundation
import IssueReporting
import Sharing

extension SharedReaderKey where Self == FileStorageKey<User>.Default {
    /// The signed-in user. While auth is mocked this always boots to
    /// ``User.mockMe``; once a real `AuthClient` is wired up, the sign-in flow
    /// will overwrite this value through `$currentUser.withLock`.
    static var currentUser: Self {
        Self[
            .fileStorage(URL.documentsDirectory.appending(component: "currentUser.json")),
            default: User.mockMe
        ]
    }
}

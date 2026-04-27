import Foundation
import Tagged

struct User: Hashable, Identifiable, Codable, Sendable {
    typealias ID = Tagged<User, UUID>

    let id: ID
    var handle: String
    var displayName: String
    var avatarURL: URL?

    init(
        id: ID,
        handle: String,
        displayName: String,
        avatarURL: URL? = nil
    ) {
        self.id = id
        self.handle = handle
        self.displayName = displayName
        self.avatarURL = avatarURL
    }
}

extension User {
    static let mockMe = Self(
        id: ID(UUID(uuidString: "00000000-0000-0000-0000-00000000ABCD")!),
        handle: "you",
        displayName: "You"
    )
}

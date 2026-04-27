import Foundation
import Tagged

struct Counter: Hashable, Identifiable, Codable, Sendable {
    typealias ID = Tagged<Counter, UUID>

    let id: ID
    var name: String
    var value: Int
    var createdAt: Date

    init(
        id: ID,
        name: String = "",
        value: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.value = value
        self.createdAt = createdAt
    }
}

extension Counter {
    static let mock = Self(
        id: ID(UUID()),
        name: "Daily push-ups",
        value: 12,
        createdAt: Date()
    )

    static let booksReadMock = Self(
        id: ID(UUID()),
        name: "Books read this year",
        value: 4,
        createdAt: Date()
    )

    static let coffeeMock = Self(
        id: ID(UUID()),
        name: "Cups of coffee",
        value: 273,
        createdAt: Date()
    )
}

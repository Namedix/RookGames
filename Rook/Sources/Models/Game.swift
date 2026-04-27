import Foundation
import Tagged

struct Game: Hashable, Identifiable, Codable, Sendable {
    typealias ID = Tagged<Game, Int>

    let id: ID
    var name: String
    var yearPublished: Int?
    var thumbnailURL: URL?
    var imageURL: URL?
    var summary: String
    var minPlayers: Int
    var maxPlayers: Int
    var minPlaytimeMinutes: Int
    var maxPlaytimeMinutes: Int
    var complexity: Double
    var categories: [String]
    var mechanics: [String]
    var designers: [String]
    var addedAt: Date

    init(
        id: ID,
        name: String,
        yearPublished: Int? = nil,
        thumbnailURL: URL? = nil,
        imageURL: URL? = nil,
        summary: String = "",
        minPlayers: Int = 1,
        maxPlayers: Int = 4,
        minPlaytimeMinutes: Int = 30,
        maxPlaytimeMinutes: Int = 60,
        complexity: Double = 2.0,
        categories: [String] = [],
        mechanics: [String] = [],
        designers: [String] = [],
        addedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.yearPublished = yearPublished
        self.thumbnailURL = thumbnailURL
        self.imageURL = imageURL
        self.summary = summary
        self.minPlayers = minPlayers
        self.maxPlayers = maxPlayers
        self.minPlaytimeMinutes = minPlaytimeMinutes
        self.maxPlaytimeMinutes = maxPlaytimeMinutes
        self.complexity = complexity
        self.categories = categories
        self.mechanics = mechanics
        self.designers = designers
        self.addedAt = addedAt
    }

    var playerRangeText: String {
        minPlayers == maxPlayers ? "\(minPlayers)" : "\(minPlayers)–\(maxPlayers)"
    }

    var playtimeText: String {
        minPlaytimeMinutes == maxPlaytimeMinutes
            ? "\(minPlaytimeMinutes) min"
            : "\(minPlaytimeMinutes)–\(maxPlaytimeMinutes) min"
    }
}

extension Game {
    static let gloomhaven = Self(
        id: 174_430,
        name: "Gloomhaven",
        yearPublished: 2017,
        summary: "Cooperative legacy-style dungeon crawler with branching campaigns and tactical hex combat.",
        minPlayers: 1,
        maxPlayers: 4,
        minPlaytimeMinutes: 60,
        maxPlaytimeMinutes: 120,
        complexity: 3.9,
        categories: ["Adventure", "Fantasy", "Fighting"],
        mechanics: ["Cooperative", "Hand Management", "Modular Board"],
        designers: ["Isaac Childres"]
    )

    static let wingspan = Self(
        id: 266_192,
        name: "Wingspan",
        yearPublished: 2019,
        summary: "Engine-builder where you attract a stunning collection of birds to your nature reserves.",
        minPlayers: 1,
        maxPlayers: 5,
        minPlaytimeMinutes: 40,
        maxPlaytimeMinutes: 70,
        complexity: 2.4,
        categories: ["Animals", "Educational"],
        mechanics: ["Engine Building", "Card Drafting", "Set Collection"],
        designers: ["Elizabeth Hargrave"]
    )

    static let azul = Self(
        id: 230_802,
        name: "Azul",
        yearPublished: 2017,
        summary: "Drafting beautiful tiles to decorate the walls of the Royal Palace of Evora.",
        minPlayers: 2,
        maxPlayers: 4,
        minPlaytimeMinutes: 30,
        maxPlaytimeMinutes: 45,
        complexity: 1.8,
        categories: ["Abstract Strategy"],
        mechanics: ["Pattern Building", "Drafting", "Set Collection"],
        designers: ["Michael Kiesling"]
    )

    static let spirit_island = Self(
        id: 162_886,
        name: "Spirit Island",
        yearPublished: 2017,
        summary: "Cooperative settler-destruction where players are spirits defending their island.",
        minPlayers: 1,
        maxPlayers: 4,
        minPlaytimeMinutes: 90,
        maxPlaytimeMinutes: 120,
        complexity: 4.0,
        categories: ["Fantasy", "Mythology"],
        mechanics: ["Cooperative", "Variable Powers", "Action Programming"],
        designers: ["R. Eric Reuss"]
    )

    static let everdell = Self(
        id: 199_792,
        name: "Everdell",
        yearPublished: 2018,
        summary: "Build a city of critters and constructions over four seasons in a charming forest.",
        minPlayers: 1,
        maxPlayers: 4,
        minPlaytimeMinutes: 40,
        maxPlaytimeMinutes: 80,
        complexity: 2.8,
        categories: ["Animals", "City Building"],
        mechanics: ["Worker Placement", "Card Drafting", "Tableau Building"],
        designers: ["James A. Wilson"]
    )

    static let catan = Self(
        id: 13,
        name: "Catan",
        yearPublished: 1995,
        summary: "Trade, build, and settle the island of Catan in this modern classic.",
        minPlayers: 3,
        maxPlayers: 4,
        minPlaytimeMinutes: 60,
        maxPlaytimeMinutes: 120,
        complexity: 2.3,
        categories: ["Negotiation", "Economic"],
        mechanics: ["Dice Rolling", "Trading", "Network Building"],
        designers: ["Klaus Teuber"]
    )

    static let sevenWonders = Self(
        id: 68_448,
        name: "7 Wonders",
        yearPublished: 2010,
        summary: "Lead one of the seven great cities of the ancient world through three ages.",
        minPlayers: 3,
        maxPlayers: 7,
        minPlaytimeMinutes: 30,
        maxPlaytimeMinutes: 30,
        complexity: 2.3,
        categories: ["Ancient", "Card Game"],
        mechanics: ["Card Drafting", "Set Collection", "Simultaneous Action"],
        designers: ["Antoine Bauza"]
    )

    static let ticketToRide = Self(
        id: 9_209,
        name: "Ticket to Ride",
        yearPublished: 2004,
        summary: "Collect train cards and claim railway routes across North America.",
        minPlayers: 2,
        maxPlayers: 5,
        minPlaytimeMinutes: 30,
        maxPlaytimeMinutes: 60,
        complexity: 1.9,
        categories: ["Trains", "Family"],
        mechanics: ["Set Collection", "Network Building", "Hand Management"],
        designers: ["Alan R. Moon"]
    )
}

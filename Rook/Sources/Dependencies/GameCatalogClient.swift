import Dependencies
import DependenciesMacros
import Foundation

/// Surface for the eventual BoardGameGeek (or equivalent) catalog backend.
/// Today every endpoint returns canned data after a short fake latency so the
/// UI can drive realistic loading states; the live impl will swap in an XML
/// adapter without touching feature code.
@DependencyClient
struct GameCatalogClient: Sendable {
    var search: @Sendable (_ query: String) async throws -> [Game]
    var lookup: @Sendable (_ id: Game.ID) async throws -> Game
    var lookupBarcode: @Sendable (_ barcode: String) async throws -> Game?
    /// Photo-of-shelf import: the AI service returns a list of probable
    /// matches. The UI lets the user multi-select before adding to collection.
    var recognizeShelf: @Sendable (_ imageData: Data) async throws -> [Game]
}

extension GameCatalogClient: TestDependencyKey {
    static let testValue = Self()

    static let previewValue = Self.mock
}

extension DependencyValues {
    var gameCatalog: GameCatalogClient {
        get { self[GameCatalogClient.self] }
        set { self[GameCatalogClient.self] = newValue }
    }
}

extension GameCatalogClient: DependencyKey {
    /// Live implementation backed by the Rook Vercel backend (see `backend/`).
    /// `search` and `lookup` hit the BGG-proxying API; `lookupBarcode` and
    /// `recognizeShelf` are still served by `.mock` until a UPC service and
    /// vision model are wired up.
    static let liveValue: Self = .live
}

extension GameCatalogClient {
    static let live: Self = {
        let baseURL: URL = {
            let raw = Bundle.main.object(forInfoDictionaryKey: "RookBackendURL") as? String
            return raw.flatMap(URL.init(string:)) ?? URL(string: "https://rook-backend.vercel.app")!
        }()

        let session = URLSession.shared
        let decoder = JSONDecoder()

        @Sendable func get(_ path: String, query: [URLQueryItem] = []) async throws -> Data {
            var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
            if !query.isEmpty {
                components?.queryItems = query
            }
            guard let url = components?.url else { throw GameCatalogError.unavailable }
            let (data, response) = try await session.data(from: url)
            guard let http = response as? HTTPURLResponse else { throw GameCatalogError.unavailable }
            switch http.statusCode {
            case 200...299: return data
            case 404: throw GameCatalogError.notFound
            default: throw GameCatalogError.unavailable
            }
        }

        return Self(
            search: { query in
                let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
                guard trimmed.count >= 2 else { return [] }
                let data = try await get(
                    "api/search",
                    query: [
                        URLQueryItem(name: "q", value: trimmed),
                        URLQueryItem(name: "limit", value: "20"),
                    ]
                )
                let dtos = try decoder.decode([BackendGameDTO].self, from: data)
                return dtos.map { $0.toGame() }
            },
            lookup: { id in
                let data = try await get("api/games/\(id.rawValue)")
                let dto = try decoder.decode(BackendGameDTO.self, from: data)
                return dto.toGame()
            },
            lookupBarcode: GameCatalogClient.mock.lookupBarcode,
            recognizeShelf: GameCatalogClient.mock.recognizeShelf
        )
    }()
}

/// Wire shape returned by the Vercel backend (`backend/src/lib/types.ts`).
/// Mirrors `Game` exactly except for `addedAt`, which is local-only and
/// stamped when the user adds the game to their collection.
private struct BackendGameDTO: Decodable, Sendable {
    let id: Int
    let name: String
    let yearPublished: Int?
    let thumbnailURL: URL?
    let imageURL: URL?
    let summary: String
    let minPlayers: Int
    let maxPlayers: Int
    let minPlaytimeMinutes: Int
    let maxPlaytimeMinutes: Int
    let complexity: Double
    let categories: [String]
    let mechanics: [String]
    let designers: [String]

    func toGame() -> Game {
        Game(
            id: Game.ID(id),
            name: name,
            yearPublished: yearPublished,
            thumbnailURL: thumbnailURL,
            imageURL: imageURL,
            summary: summary,
            minPlayers: minPlayers,
            maxPlayers: maxPlayers,
            minPlaytimeMinutes: minPlaytimeMinutes,
            maxPlaytimeMinutes: maxPlaytimeMinutes,
            complexity: complexity,
            categories: categories,
            mechanics: mechanics,
            designers: designers
        )
    }
}

extension GameCatalogClient {
    static let mock: Self = {
        @Sendable func sleep(_ seconds: Double) async throws {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
        }

        let catalog: [Game] = [
            .gloomhaven, .wingspan, .azul, .spirit_island,
            .everdell, .catan, .sevenWonders, .ticketToRide,
        ]

        // Pretend EAN-13 → BGG id map for the barcode flow.
        let barcodeIndex: [String: Game] = [
            "0681706711461": .gloomhaven,
            "0810023363125": .wingspan,
            "0826956000389": .azul,
            "0653341057860": .spirit_island,
            "0810054590004": .everdell,
            "0029877030712": .catan,
            "0824968717707": .sevenWonders,
            "0824968117309": .ticketToRide,
        ]

        return Self(
            search: { query in
                try await sleep(0.4)
                let needle = query.lowercased()
                guard !needle.isEmpty else { return catalog }
                return catalog.filter { game in
                    game.name.lowercased().contains(needle)
                        || game.designers.contains(where: { $0.lowercased().contains(needle) })
                        || game.categories.contains(where: { $0.lowercased().contains(needle) })
                        || game.mechanics.contains(where: { $0.lowercased().contains(needle) })
                }
            },
            lookup: { id in
                try await sleep(0.25)
                guard let game = catalog.first(where: { $0.id == id }) else {
                    throw GameCatalogError.notFound
                }
                return game
            },
            lookupBarcode: { barcode in
                try await sleep(0.3)
                return barcodeIndex[barcode]
            },
            recognizeShelf: { _ in
                try await sleep(1.2)
                return [.gloomhaven, .wingspan, .everdell, .azul]
            }
        )
    }()
}

enum GameCatalogError: Error, Equatable {
    case notFound
    case unavailable
}

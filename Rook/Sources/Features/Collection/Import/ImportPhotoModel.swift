import Dependencies
import SwiftUI

@MainActor
@Observable
final class ImportPhotoModel: ImportMethodModel {
    enum Status: Equatable {
        case picking
        case analyzing
        case results
        case failed(String)
    }

    var status: Status = .picking
    var candidates: [Game] = []
    var selectedIDs: Set<Game.ID> = []

    var onConfirm: ([Game]) -> Void = { _ in }

    @ObservationIgnored @Dependency(\.gameCatalog) var catalog

    init() {}

    func photoSelected(data: Data) async {
        status = .analyzing
        candidates = []
        selectedIDs = []
        do {
            let games = try await catalog.recognizeShelf(imageData: data)
            candidates = games
            selectedIDs = Set(games.map(\.id))
            status = .results
        } catch {
            status = .failed(error.localizedDescription)
        }
    }

    func toggle(_ game: Game) {
        if selectedIDs.contains(game.id) {
            selectedIDs.remove(game.id)
        } else {
            selectedIDs.insert(game.id)
        }
    }

    func retryButtonTapped() {
        status = .picking
        candidates = []
        selectedIDs = []
    }

    func confirmButtonTapped() {
        let chosen = candidates.filter { selectedIDs.contains($0.id) }
        guard !chosen.isEmpty else { return }
        onConfirm(chosen)
    }
}

extension ImportPhotoModel: Identifiable, Hashable {
    nonisolated var id: ObjectIdentifier { ObjectIdentifier(self) }

    nonisolated static func == (lhs: ImportPhotoModel, rhs: ImportPhotoModel) -> Bool {
        lhs === rhs
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

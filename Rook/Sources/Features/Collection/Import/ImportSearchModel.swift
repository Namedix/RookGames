import Dependencies
import SwiftUI

@MainActor
@Observable
final class ImportSearchModel: ImportMethodModel {
    var query = ""
    var results: [Game] = []
    var isLoading = false
    var errorMessage: String?
    var selectedIDs: Set<Game.ID> = []

    var onConfirm: ([Game]) -> Void = { _ in }

    @ObservationIgnored @Dependency(\.gameCatalog) var catalog

    init() {}

    func task() async {
        await runSearch()
    }

    func queryChanged() async {
        await runSearch()
    }

    private func runSearch() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            results = try await catalog.search(query: query)
        } catch {
            errorMessage = error.localizedDescription
            results = []
        }
    }

    func toggle(_ game: Game) {
        if selectedIDs.contains(game.id) {
            selectedIDs.remove(game.id)
        } else {
            selectedIDs.insert(game.id)
        }
    }

    func confirmButtonTapped() {
        let chosen = results.filter { selectedIDs.contains($0.id) }
        guard !chosen.isEmpty else { return }
        onConfirm(chosen)
    }
}

extension ImportSearchModel: Identifiable, Hashable {
    nonisolated var id: ObjectIdentifier { ObjectIdentifier(self) }

    nonisolated static func == (lhs: ImportSearchModel, rhs: ImportSearchModel) -> Bool {
        lhs === rhs
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

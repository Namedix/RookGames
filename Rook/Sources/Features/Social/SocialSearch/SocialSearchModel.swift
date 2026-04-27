import Dependencies
import SwiftUI

@MainActor
@Observable
final class SocialSearchModel {
    var query = ""
    var results: [LibrarySearchHit] = []
    var isLoading = false
    var errorMessage: String?

    @ObservationIgnored @Dependency(\.social) var social

    private var task: Task<Void, Never>?

    init() {}

    func queryChanged() {
        task?.cancel()
        let snapshot = query
        task = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 250_000_000)
            if Task.isCancelled { return }
            await self?.runSearch(query: snapshot)
        }
    }

    private func runSearch(query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            results = []
            isLoading = false
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            results = try await social.searchLibraries(query: trimmed)
        } catch {
            errorMessage = error.localizedDescription
            results = []
        }
    }
}

extension SocialSearchModel: Identifiable, Hashable {
    nonisolated var id: ObjectIdentifier { ObjectIdentifier(self) }

    nonisolated static func == (lhs: SocialSearchModel, rhs: SocialSearchModel) -> Bool {
        lhs === rhs
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

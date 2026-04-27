import CasePaths
import Dependencies
import IdentifiedCollections
import Sharing
import SwiftUI
import SwiftUINavigation

@MainActor
@Observable
final class CollectionListModel {
    var destination: Destination?
    var searchText = ""
    var sort: Sort = .recent

    @ObservationIgnored @Shared(.collection) var collection
    @ObservationIgnored @Dependency(\.uuid) var uuid

    var onGameTapped: (Game.ID) -> Void = { _ in }

    @CasePathable
    @dynamicMemberLookup
    enum Destination {
        case importFlow(ImportFlowModel)
    }

    enum Sort: String, CaseIterable, Hashable {
        case recent = "Recently added"
        case name = "Name"
        case complexity = "Complexity"
    }

    init(destination: Destination? = nil) {
        self.destination = destination
    }

    var filteredGames: [Game] {
        let needle = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let games = needle.isEmpty
            ? Array(collection)
            : collection.filter { $0.name.lowercased().contains(needle) }

        switch sort {
        case .recent:
            return games.sorted { $0.addedAt > $1.addedAt }
        case .name:
            return games.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .complexity:
            return games.sorted { $0.complexity > $1.complexity }
        }
    }

    func gameTapped(id: Game.ID) {
        onGameTapped(id)
    }

    func addButtonTapped() {
        let flow = withDependencies(from: self) { ImportFlowModel() }
        flow.onImport = { [weak self] games in
            guard let self else { return }
            $collection.withLock { current in
                for game in games where current[id: game.id] == nil {
                    var stamped = game
                    stamped.addedAt = Date()
                    current.append(stamped)
                }
            }
            destination = nil
        }
        flow.onCancel = { [weak self] in
            self?.destination = nil
        }
        destination = .importFlow(flow)
    }

    func dismissImport() {
        destination = nil
    }

    func removeGame(id: Game.ID) {
        $collection.withLock { $0.remove(id: id) }
    }
}

extension CollectionListModel: Identifiable, Hashable {
    nonisolated var id: ObjectIdentifier { ObjectIdentifier(self) }

    nonisolated static func == (lhs: CollectionListModel, rhs: CollectionListModel) -> Bool {
        lhs === rhs
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

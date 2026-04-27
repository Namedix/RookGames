import Dependencies
import SwiftUI

@MainActor
@Observable
final class AppModel {
    enum Tab: Hashable, CaseIterable {
        case collection
        case plays
        case social
        case profile
    }

    var selectedTab: Tab = .collection

    var collection: CollectionTabModel { didSet { bind() } }
    var plays: PlaysTabModel           { didSet { bind() } }
    var social: SocialTabModel         { didSet { bind() } }
    var profile: ProfileTabModel       { didSet { bind() } }

    @ObservationIgnored @Dependency(\.continuousClock) var clock
    @ObservationIgnored @Dependency(\.date.now) var now
    @ObservationIgnored @Dependency(\.uuid) var uuid

    init(
        selectedTab: Tab = .collection,
        collection: CollectionTabModel = CollectionTabModel(),
        plays: PlaysTabModel = PlaysTabModel(),
        social: SocialTabModel = SocialTabModel(),
        profile: ProfileTabModel = ProfileTabModel()
    ) {
        self.selectedTab = selectedTab
        self.collection = collection
        self.plays = plays
        self.social = social
        self.profile = profile
        self.bind()
    }

    /// Cross-tab effects. Keeps tabs decoupled at construction time but lets
    /// the parent reach into them when one tab's actions affect another.
    private func bind() {
        // Future: wire e.g. collection.list.onLogPlayTapped to switch tabs and
        // pre-fill the play form. No cross-tab hooks are active yet.
    }
}

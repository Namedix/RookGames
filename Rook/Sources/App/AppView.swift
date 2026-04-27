import SwiftUI

struct AppView: View {
    @Bindable var model: AppModel

    var body: some View {
        TabView(selection: $model.selectedTab) {
            collectionTab
                .tabItem { Label("Library", systemImage: "square.grid.2x2") }
                .tag(AppModel.Tab.collection)

            playsTab
                .tabItem { Label("Plays", systemImage: "list.bullet.rectangle") }
                .tag(AppModel.Tab.plays)

            socialTab
                .tabItem { Label("Friends", systemImage: "person.2") }
                .tag(AppModel.Tab.social)

            profileTab
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
                .tag(AppModel.Tab.profile)
        }
        .tint(.rookAccent)
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var collectionTab: some View {
        @Bindable var collection = model.collection
        NavigationStack(path: $collection.path) {
            CollectionListView(model: collection.list)
                .navigationDestination(for: CollectionTabModel.Path.self) { path in
                    switch path {
                    case let .gameDetail(model):
                        GameDetailView(model: model)
                    case let .gameStats(model):
                        GameStatsView(model: model)
                    }
                }
        }
    }

    @ViewBuilder
    private var playsTab: some View {
        @Bindable var plays = model.plays
        NavigationStack(path: $plays.path) {
            PlaysListView(model: plays.list)
                .navigationDestination(for: PlaysTabModel.Path.self) { path in
                    switch path {
                    case let .playDetail(model):
                        PlayDetailView(model: model)
                    case let .statsOverview(model):
                        StatsOverviewView(model: model)
                    }
                }
        }
    }

    @ViewBuilder
    private var socialTab: some View {
        @Bindable var social = model.social
        NavigationStack(path: $social.path) {
            FriendsListView(model: social.list)
                .navigationDestination(for: SocialTabModel.Path.self) { path in
                    switch path {
                    case let .friendDetail(model):
                        FriendDetailView(model: model)
                    case let .search(model):
                        SocialSearchView(model: model)
                    }
                }
        }
    }

    @ViewBuilder
    private var profileTab: some View {
        NavigationStack {
            ProfileTabView(model: model.profile)
        }
    }
}

#Preview("Happy path") {
    AppView(model: AppModel())
}

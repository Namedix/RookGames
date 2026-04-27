import SwiftUI

struct AppView: View {
    @Bindable var model: AppModel

    var body: some View {
        NavigationStack(path: $model.path) {
            CountersListView(model: model.countersList)
                .navigationDestination(for: AppModel.Path.self) { path in
                    switch path {
                    case let .detail(model):
                        CounterDetailView(model: model)
                    }
                }
        }
    }
}

#Preview("Happy path") {
    AppView(model: AppModel())
}

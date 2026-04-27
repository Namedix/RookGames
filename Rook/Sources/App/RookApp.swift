import SwiftUI

@main
struct RookApp: App {
    @State private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            AppView(model: model)
        }
    }
}

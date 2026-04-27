import SwiftUI

@main
struct RookApp: App {
    @State private var model = AppModel()

    init() {
        RookTheme.bootstrap()
    }

    var body: some Scene {
        WindowGroup {
            AppView(model: model)
        }
    }
}

import SwiftUI

@main
struct DailyAlbumApp: App {
    @State private var viewModel = AlbumViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
        }
        .windowResizability(.contentSize)

        Settings {
            SettingsView()
                .environment(viewModel)
        }
    }
}

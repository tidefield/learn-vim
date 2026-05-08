import SwiftUI

@main
struct LearnVimApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // We use LSUIElement=true so no main window.
        // The floating panel is managed by AppDelegate.
        Settings {
            EmptyView()
        }
    }
}

import SwiftUI

@main
struct VoiceMemoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Menubar-only app — no windows managed by SwiftUI
        Settings {
            EmptyView()
        }
    }
}

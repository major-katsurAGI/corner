import SwiftUI

@main
struct CornerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appDelegate.appState)
        }
        .commands {
            CommandMenu("File") {
                Button("Select Folder...") {
                    NSApp.sendAction(#selector(AppDelegate.selectFolder), to: appDelegate, from: nil)
                }
            }
        }
    }
}

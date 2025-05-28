import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    let appState = AppState()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set the window to stay on top once it’s created by SwiftUI
        if let window = NSApplication.shared.windows.first {
            window.level = .floating
        }
    }

    @objc func selectFolder() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.begin { result in
            if result == .OK, let url = openPanel.url {
                self.appState.selectedFolder = url
            }
        }
    }
}

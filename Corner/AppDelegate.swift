import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    let appState = AppState()
    var mainWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.level = .floating
            mainWindow = window
        }
        appState.selectFolder = { [weak self] in
            self?.selectFolder()
        }
    }

    @objc func selectFolder() {
        guard let window = mainWindow else { return }
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.beginSheetModal(for: window) { result in
            if result == .OK, let url = openPanel.url {
                self.appState.selectedFolder = url
            }
        }
    }
}

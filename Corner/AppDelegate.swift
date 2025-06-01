import Cocoa
import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    var panel: DraggablePanel!
    let appState = AppState()
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the DraggablePanel
        panel = DraggablePanel(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered, defer: false
        )
        
        // Configure panel to stay on top and appear in all spaces
        panel.level = .screenSaver
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.hidesOnDeactivate = false
        panel.backgroundColor = .clear
        panel.center()
        
        // Inject AppState into the ContentView's environment
        let contentView = ContentView()
            .environmentObject(appState)
        
        // Set the SwiftUI content and ensure it fills the panel
        let hostingView = NSHostingView(rootView: contentView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        panel.contentView = hostingView
        
        // Constrain hostingView to fill the panel
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: panel.contentView!.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: panel.contentView!.bottomAnchor),
            hostingView.leadingAnchor.constraint(equalTo: panel.contentView!.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: panel.contentView!.trailingAnchor)
        ])
        
        panel.makeKeyAndOrderFront(nil)
        
        // Set up folder selection closure
        appState.selectFolder = { [weak self] in
            self?.selectFolder()
        }
        
        // Observe image size changes to resize the panel
        appState.$currentImageSize
            .sink { [weak self] size in
                guard let self = self, let size = size else { return }
                // Get current top-left corner
                let currentFrame = self.panel.frame
                let topLeft = NSPoint(x: currentFrame.minX, y: currentFrame.maxY)
                
                // Create new frame with fixed top-left
                let newFrame = NSRect(
                    x: topLeft.x,
                    y: topLeft.y - size.height,
                    width: size.width,
                    height: size.height
                )
                
                // Update panel frame
                self.panel.setFrame(newFrame, display: true, animate: true)
            }
            .store(in: &cancellables)
    }

    @objc func selectFolder() {
        guard let window = panel else { return }
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

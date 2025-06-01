import Cocoa
import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    var panel: DraggablePanel!
    let appState = AppState()
    private var cancellables = Set<AnyCancellable>()
    private let fixedHeight: CGFloat = 300

    func applicationDidFinishLaunching(_ notification: Notification) {
        panel = DraggablePanel(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: fixedHeight),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered, defer: false
        )
        panel.level = .screenSaver
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.hidesOnDeactivate = false
        panel.backgroundColor = .black.withAlphaComponent(0.5)
        panel.center()

        panel.contentView = NSHostingView(rootView: ContentView().environmentObject(appState))
        panel.makeKeyAndOrderFront(nil)

        appState.selectFolder = { [weak self] in self?.selectFolder() }

        // Resize panel on every new image size (no animation → no slide-in effect)
        appState.$currentImageSize
            .receive(on: RunLoop.main)
            .sink { [weak self] size in
                guard
                    let self,
                    let size
                else { return }

                let newFrame = self.frame(for: size, anchored: self.appState.anchor)
                self.panel.setFrame(newFrame, display: true, animate: false)   // ← animate: false
            }
            .store(in: &cancellables)
    }

    // MARK: - Folder picker
    private func selectFolder() {
        guard let window = panel else { return }
        let open = NSOpenPanel()
        open.canChooseDirectories = true
        open.canChooseFiles = false

        open.beginSheetModal(for: window) { result in
            if result == .OK { self.appState.selectedFolder = open.url }
        }
    }

    // MARK: - Keep chosen edge fixed while resizing (panel itself still draggable)
    private func frame(for newSize: NSSize, anchored side: Anchor) -> NSRect {
        let current = panel.frame

        switch side {
        case .left:
            return NSRect(x: current.minX,
                          y: current.minY,
                          width: newSize.width,
                          height: newSize.height)

        case .right:
            let newX = current.maxX - newSize.width
            return NSRect(x: newX,
                          y: current.minY,
                          width: newSize.width,
                          height: newSize.height)
        }
    }
}

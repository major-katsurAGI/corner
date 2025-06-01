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
        panel.backgroundColor = .black.withAlphaComponent(0.5) // Translucent black at 50% opacity
        panel.center()

        let contentView = ContentView().environmentObject(appState)
        let hostingView = NSHostingView(rootView: contentView)
        panel.contentView = hostingView
        panel.makeKeyAndOrderFront(nil)

        appState.selectFolder = { [weak self] in
            self?.selectFolder()
        }

        appState.$currentImageSize
            .sink { [weak self] size in
                guard let self = self, let size = size else { return }
                let currentFrame = self.panel.frame
                let anchor = self.appState.anchor
                let newFrame = self.newFrameForAnchor(currentFrame: currentFrame, newSize: size, anchor: anchor)
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

    private func newFrameForAnchor(currentFrame: NSRect, newSize: NSSize, anchor: Anchor) -> NSRect {
        switch anchor {
        case .topLeft:
            let newX = currentFrame.minX
            let newY = currentFrame.maxY - newSize.height
            return NSRect(x: newX, y: newY, width: newSize.width, height: newSize.height)
        case .topRight:
            let newX = currentFrame.maxX - newSize.width
            let newY = currentFrame.maxY - newSize.height
            return NSRect(x: newX, y: newY, width: newSize.width, height: newSize.height)
        case .bottomLeft:
            let newX = currentFrame.minX
            let newY = currentFrame.minY
            return NSRect(x: newX, y: newY, width: newSize.width, height: newSize.height)
        case .bottomRight:
            let newX = currentFrame.maxX - newSize.width
            let newY = currentFrame.minY
            return NSRect(x: newX, y: newY, width: newSize.width, height: newSize.height)
        }
    }
}

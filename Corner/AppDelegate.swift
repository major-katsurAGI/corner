import Cocoa
import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    var panel: DraggablePanel!
    let appState = AppState()
    private var cancellables = Set<AnyCancellable>()
    private let fixedHeight: CGFloat = 220
    private let cornerRadius: CGFloat = 16     // <- adjust if you want rounder / squarer

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Borderless, always-on-top panel
        panel = DraggablePanel(
            contentRect: NSRect(x: 0, y: 0, width: 350, height: appState.fixedHeight),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.appState = appState
        panel.acceptsMouseMovedEvents = true
        panel.level = .screenSaver
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.hidesOnDeactivate = false
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.center()
        panel.isMovableByWindowBackground = true

        let hostingView = DragHostingView(rootView: ContentView().environmentObject(appState))
        panel.contentView = hostingView

        // --- Rounded corners & translucent backdrop -------------------------
        hostingView.wantsLayer = true
        if let layer = hostingView.layer {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
            layer.backgroundColor = NSColor.black.withAlphaComponent(0.85).cgColor
        }
        // --------------------------------------------------------------------

        panel.makeKeyAndOrderFront(nil)

        appState.selectFolder = { [weak self] in self?.selectFolder() }

        // Resize panel whenever a new image size comes in
        appState.$currentImageSize
            .receive(on: RunLoop.main)
            .sink { [weak self] size in
                guard
                    let self,
                    let size
                else { return }

                let newFrame = self.frame(for: size, anchored: self.appState.anchor)
                self.panel.setFrame(newFrame, display: true, animate: false)   // no slide-in animation
            }
            .store(in: &cancellables)
        
        if let data = UserDefaults.standard.data(forKey: "lastFolderBookmark") {
            var stale = false
            if let url = try? URL(resolvingBookmarkData: data,
                                  options: [.withSecurityScope],
                                  relativeTo: nil,
                                  bookmarkDataIsStale: &stale),
               !stale, url.startAccessingSecurityScopedResource() {
                appState.selectedFolder = url          // kicks off loadImages → startRotation
            }
        }
        
        NSApp.setActivationPolicy(.accessory)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            if let image = NSImage(named: "CornerMenuIcon") {
                image.size = NSSize(width: 12, height: 12)
                image.isTemplate = true
                button.image = image
            }
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(
            title: "Quit Corner",
            action: #selector(quitApp),
            keyEquivalent: "q"))
        statusItem?.menu = menu
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

    // MARK: - Keep chosen edge fixed while resizing (panel still draggable)
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
    
    @objc private func quitApp(_ sender: Any?) {
        NSApp.terminate(sender)
    }
}


import SwiftUI

final class DragHostingView<Content: View>: NSHostingView<Content> {
    // one-line fix: the first mouse-down can move the window
    override var mouseDownCanMoveWindow: Bool { true }

    // optional: still deliver the click to buttons etc. on first hit
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
}

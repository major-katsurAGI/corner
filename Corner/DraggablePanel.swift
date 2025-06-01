import Cocoa

class DraggablePanel: NSPanel {
    var initialLocation: NSPoint?

    override var canBecomeKey: Bool {
        return true
    }

    override func mouseDown(with event: NSEvent) {
        initialLocation = event.locationInWindow
        super.mouseDown(with: event)
    }

    override func mouseDragged(with event: NSEvent) {
        guard let initialLocation = initialLocation else { return }
        let currentLocation = event.locationInWindow
        let deltaX = currentLocation.x - initialLocation.x
        let deltaY = currentLocation.y - initialLocation.y
        var newOrigin = self.frame.origin
        newOrigin.x += deltaX
        newOrigin.y += deltaY
        self.setFrameOrigin(newOrigin)
    }

    override func mouseUp(with event: NSEvent) {
        initialLocation = nil
        super.mouseUp(with: event)
    }
}

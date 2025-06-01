import Cocoa

class DraggablePanel: NSPanel {
    var initialLocation: NSPoint?

    override var canBecomeKey: Bool {
        return true // Allow the panel to receive mouse events
    }

    override func mouseDown(with event: NSEvent) {
        // Store the initial mouse location
        initialLocation = event.locationInWindow
        super.mouseDown(with: event)
    }

    override func mouseDragged(with event: NSEvent) {
        guard let initialLocation = initialLocation else { return }
        
        // Calculate the new origin based on mouse movement
        let currentLocation = event.locationInWindow
        let deltaX = currentLocation.x - initialLocation.x
        let deltaY = currentLocation.y - initialLocation.y
        
        var newOrigin = self.frame.origin
        newOrigin.x += deltaX
        newOrigin.y += deltaY
        
        // Update the panel's position
        self.setFrameOrigin(newOrigin)
    }

    override func mouseUp(with event: NSEvent) {
        // Clear the initial location
        initialLocation = nil
        super.mouseUp(with: event)
    }
}

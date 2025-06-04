import Cocoa

class DraggablePanel: NSPanel {
    weak var appState: AppState!

    // ── constants ──────────────────────────────────────────────────────────
    private let band:   CGFloat = 20          // thickness of resize zone
    private let minH:   CGFloat = 165
    private let maxH:   CGFloat = 500

    // ── drag state ─────────────────────────────────────────────────────────
    private var resizing  = false
    private var startPt   = NSPoint.zero      // global mouse position
    private var startH:   CGFloat = 0
    private var startTop: CGFloat = 0         // keeps top edge from moving
    private var startOrg  = NSPoint.zero      // for move path

    override var canBecomeKey: Bool { true }

    private func insideBand(_ p: NSPoint) -> Bool { p.y <= band }

    // ── cursor feedback ────────────────────────────────────────────────────
    override func cursorUpdate(with e: NSEvent) {
        insideBand(e.locationInWindow) ? NSCursor.resizeUpDown.set()
                                       : NSCursor.arrow.set()
    }

    // ── mouse chain ────────────────────────────────────────────────────────
    override func mouseDown(with e: NSEvent) {
        resizing  = insideBand(e.locationInWindow)
        startPt   = NSEvent.mouseLocation          // global coords
        startH    = frame.height
        startTop  = frame.maxY
        startOrg  = frame.origin
        if !isKeyWindow { makeKey() }
    }

    override func mouseDragged(with e: NSEvent) {
        let now = NSEvent.mouseLocation
        let dx  = now.x - startPt.x
        let dy  = now.y - startPt.y

        if resizing {
            //------------------------------------------------ RESIZE -------
            var newH = startH - dy                 // drag up shrinks
            newH     = max(minH, min(maxH, newH))  // clamp

            // only act if height really changed (saves work & stops jitter)
            if abs(frame.height - newH) >= 0.5 {
                let newY = startTop - newH         // top edge anchored
                setFrame(NSRect(x: frame.origin.x, y: newY,
                                width: frame.width, height: newH),
                         display: true, animate: false)

                // SwiftUI sync
                appState.fixedHeight = newH
                if let sz = appState.currentImageSize {
                    let ratio = sz.width / max(sz.height, 1)
                    appState.currentImageSize = .init(width: newH * ratio,
                                                      height: newH)
                }
            }
        } else {
            //------------------------------------------------ MOVE  -------
            setFrameOrigin(NSPoint(x: startOrg.x + dx,
                                   y: startOrg.y + dy))
        }
    }

    override func mouseUp(with e: NSEvent) {
        resizing = false
    }
}

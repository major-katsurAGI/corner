import Foundation

enum Anchor {
    case left
    case right
}

class AppState: ObservableObject {
    @Published var selectedFolder: URL?
    @Published var currentImageSize: NSSize?
    @Published var anchor: Anchor = .left      // default: left edge
    var selectFolder: (() -> Void)?
}

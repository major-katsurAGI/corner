import Foundation

enum Anchor {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}

class AppState: ObservableObject {
    @Published var selectedFolder: URL?
    @Published var currentImageSize: NSSize?
    @Published var anchor: Anchor = .topLeft
    var selectFolder: (() -> Void)?
}

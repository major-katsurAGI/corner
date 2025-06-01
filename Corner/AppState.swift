import Foundation

class AppState: ObservableObject {
    @Published var selectedFolder: URL?
    @Published var currentImageSize: NSSize?
    var selectFolder: (() -> Void)?
}

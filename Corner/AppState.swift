import Foundation

enum Anchor {
    case left
    case right
}

class AppState: ObservableObject {
    @Published var selectedFolder: URL? {
        didSet {
            // stop any previous scope
            if let old = oldValue { old.stopAccessingSecurityScopedResource() }

            if let url = selectedFolder {                // new folder ➞ save bookmark + open scope
                if let data = try? url.bookmarkData(options: .withSecurityScope,
                                                    includingResourceValuesForKeys: nil,
                                                    relativeTo: nil) {
                    UserDefaults.standard.set(data, forKey: "lastFolderBookmark")
                    _ = url.startAccessingSecurityScopedResource()
                }
            } else {                                     // cleared ➞ remove bookmark
                UserDefaults.standard.removeObject(forKey: "lastFolderBookmark")
            }
        }
    }

    @Published var currentImageSize: NSSize?
    @Published var anchor: Anchor = .left
    @Published var fixedHeight: CGFloat = 220

    var selectFolder: (() -> Void)?
    func clearSelection() { selectedFolder = nil }   // keeps UI logic in one place
}


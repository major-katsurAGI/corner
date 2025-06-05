import Foundation

enum Anchor: String {
    case left, right
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
    @Published var fixedHeight: CGFloat {                 // <-- replace old line
        didSet { UserDefaults.standard.set(Double(fixedHeight), forKey: "fixedHeight") }
    }
    @Published var anchor: Anchor {
        didSet { UserDefaults.standard.set(anchor.rawValue, forKey: "anchorSide") }
    }

    var selectFolder: (() -> Void)?
    func clearSelection() { selectedFolder = nil }   // keeps UI logic in one place
    
    init() {
        if let raw = UserDefaults.standard.string(forKey: "anchorSide"),
           let saved = Anchor(rawValue: raw) { anchor = saved }
        else { anchor = .left }
        
        let savedHeight = UserDefaults.standard.double(forKey: "fixedHeight")
        if (165...500).contains(savedHeight) { fixedHeight = CGFloat(savedHeight) }
        else { fixedHeight = 220 }
    }
}


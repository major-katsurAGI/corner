import Foundation

class AppState: ObservableObject {
    @Published var selectedFolder: URL?
}

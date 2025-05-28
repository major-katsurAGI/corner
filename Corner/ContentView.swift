import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var imageURLs: [URL] = []
    @State private var currentImageIndex = 0
    @State private var timer: Timer?
    @State private var isHovering = false

    var body: some View {
        VStack {
            if let imageURL = imageURLs[safe: currentImageIndex], let image = NSImage(contentsOf: imageURL) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Text("Select a folder to display images")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onHover { hovering in
            isHovering = hovering
        }
        .overlay(alignment: .bottomTrailing) {
            if isHovering || appState.selectedFolder == nil {
                Button(action: { appState.selectFolder?() }) {
                    Image(systemName: "folder")
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
                .padding()
            }
        }
        .onChange(of: appState.selectedFolder) { newFolder in
            if let folder = newFolder {
                loadImages(from: folder)
            }
        }
    }

    private func loadImages(from folder: URL) {
        let imageExtensions = ["jpg", "jpeg", "png", "gif", "bmp", "heic"]
        imageURLs = (try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
            .filter { imageExtensions.contains($0.pathExtension.lowercased()) }) ?? []
        currentImageIndex = 0
        startImageRotation()
    }

    private func startImageRotation() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            if !imageURLs.isEmpty {
                currentImageIndex = (currentImageIndex + 1) % imageURLs.count
            }
        }
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

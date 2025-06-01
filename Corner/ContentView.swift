import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var imageURLs: [URL] = []
    @State private var currentImageIndex = 0
    @State private var timer: Timer?
    @State private var isHovering = false
    
    // Fixed height for the panel
    private let fixedHeight: CGFloat = 300

    var body: some View {
        VStack {
            // Display the current image or a placeholder
            if let imageURL = imageURLs[safe: currentImageIndex], let image = NSImage(contentsOf: imageURL) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        // Calculate the scaled width based on fixed height
                        let aspectRatio = image.size.width / max(image.size.height, 1) // Avoid division by zero
                        let scaledWidth = fixedHeight * aspectRatio
                        appState.currentImageSize = NSSize(width: max(scaledWidth, 200), height: fixedHeight) // Minimum width
                    }
            } else {
                Text("Select a folder to display images")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        // Default size when no image is selected
                        appState.currentImageSize = NSSize(width: 480, height: fixedHeight)
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
        .onHover { hovering in
            isHovering = hovering
        }
        .overlay(alignment: .bottomTrailing) {
            // Show folder button on hover or when no folder is selected
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
        .onChange(of: currentImageIndex) { _ in
            // Update size when image changes
            if let imageURL = imageURLs[safe: currentImageIndex], let image = NSImage(contentsOf: imageURL) {
                let aspectRatio = image.size.width / max(image.size.height, 1)
                let scaledWidth = fixedHeight * aspectRatio
                appState.currentImageSize = NSSize(width: max(scaledWidth, 200), height: fixedHeight)
            }
        }
    }

    // Load images from the selected folder
    private func loadImages(from folder: URL) {
        let imageExtensions = ["jpg", "jpeg", "png", "gif", "bmp", "heic"]
        imageURLs = (try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
            .filter { imageExtensions.contains($0.pathExtension.lowercased()) }) ?? []
        currentImageIndex = 0
        startImageRotation()
    }

    // Start the timer for image rotation
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

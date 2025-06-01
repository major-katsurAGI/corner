import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var imageURLs: [URL] = []
    @State private var currentImageIndex = 0
    @State private var timer: Timer?
    @State private var isHovering = false
    private let fixedHeight: CGFloat = 300

    var buttonAlignment: Alignment {
        switch appState.anchor {
        case .topLeft, .bottomLeft:
            return .bottomLeading
        case .topRight, .bottomRight:
            return .bottomTrailing
        }
    }

    var body: some View {
        ZStack(alignment: buttonAlignment) {
            HStack {
                if let imageURL = imageURLs[safe: currentImageIndex], let image = NSImage(contentsOf: imageURL) {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: fixedHeight)
                        .onAppear {
                            updateImageSize(for: image)
                        }
                } else {
                    Text("Select a folder to display images")
                        .frame(height: fixedHeight)
                }
                Spacer()
            }
            .frame(height: fixedHeight)

            if isHovering || appState.selectedFolder == nil {
                HStack {
                    Button(action: { appState.selectFolder?() }) {
                        Image(systemName: "folder")
                            .padding(8)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    Menu {
                        Button("Top Left") { appState.anchor = .topLeft }
                        Button("Top Right") { appState.anchor = .topRight }
                        Button("Bottom Left") { appState.anchor = .bottomLeft }
                        Button("Bottom Right") { appState.anchor = .bottomRight }
                    } label: {
                        Image(systemName: "pin")
                            .padding(8)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding()
            }
        }
        .frame(width: appState.currentImageSize?.width ?? 480, height: fixedHeight)
        .background(Color.clear)
        .onHover { hovering in
            isHovering = hovering
        }
        .onChange(of: appState.selectedFolder) { newFolder in
            if let folder = newFolder {
                loadImages(from: folder)
            }
        }
        .onAppear {
            if appState.currentImageSize == nil {
                appState.currentImageSize = NSSize(width: 480, height: fixedHeight)
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

    private func updateImageSize(for image: NSImage) {
        let aspectRatio = image.size.width / max(image.size.height, 1)
        let scaledWidth = fixedHeight * aspectRatio
        appState.currentImageSize = NSSize(width: max(scaledWidth, 200), height: fixedHeight)
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

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState

    @State private var imageURLs: [URL] = []
    @State private var currentImageIndex = 0
    @State private var currentImage: NSImage?
    @State private var timer: Timer?
    @State private var isHovering = false

    private let fixedHeight: CGFloat = 300
    private let rotationInterval: TimeInterval = 30

    // Buttons sit in the same corner as the image edge
    private var buttonAlignment: Alignment {
        appState.anchor == .left ? .bottomLeading : .bottomTrailing
    }

    var body: some View {
        ZStack(alignment: buttonAlignment) {

            // Image row ­– zero-spacing HStack keeps image flush to chosen edge
            HStack(spacing: 0) {
                if appState.anchor == .right { Spacer(minLength: 0) }

                contentImage()
                    .frame(height: fixedHeight)

                if appState.anchor == .left  { Spacer(minLength: 0) }
            }
            .frame(height: fixedHeight)

            // Hover controls
            if isHovering || appState.selectedFolder == nil {
                controls
            }
        }
        .frame(width: appState.currentImageSize?.width ?? 480,
               height: fixedHeight)
        .background(Color.clear)
        .onHover { isHovering = $0 }
        .onChange(of: appState.selectedFolder) { folder in
            if let folder { loadImages(from: folder) }
        }
        .onAppear {
            if appState.currentImageSize == nil {
                appState.currentImageSize = NSSize(width: 480, height: fixedHeight)
            }
        }
    }

    // MARK: - Image / placeholder
    @ViewBuilder
    private func contentImage() -> some View {
        if let image = currentImage {
            Image(nsImage: image)
                .resizable()
                .interpolation(.high)
                .aspectRatio(contentMode: .fit)   // fills full height; width matches panel
        } else {
            Text("Select a folder to display images")
                .frame(maxWidth: .infinity,            // fill entire panel width
                       maxHeight: .infinity,           // fill height
                       alignment: .center)             // center horizontally & vertically
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Hover controls
    private var controls: some View {
        HStack {
            Button(action: { appState.selectFolder?() }) {
                Image(systemName: "folder")
                    .padding(8)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }

            Menu {
                Button("Left Edge")  { appState.anchor = .left  }
                Button("Right Edge") { appState.anchor = .right }
            } label: {
                Image(systemName: "arrow.left.and.right")
                    .padding(8)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
        }
        .buttonStyle(.plain)
        .padding()
    }

    // MARK: - Image loading & rotation
    private func loadImages(from folder: URL) {
        timer?.invalidate()

        DispatchQueue.global(qos: .userInitiated).async {
            let exts = ["jpg", "jpeg", "png", "gif", "bmp", "heic"]
            let urls = (try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
                .filter { exts.contains($0.pathExtension.lowercased()) }) ?? []

            DispatchQueue.main.async {
                imageURLs = urls
                currentImageIndex = 0
                if let first = urls.first { loadImageAsync(at: first) }
                startRotation()
            }
        }
    }

    private func startRotation() {
        timer = Timer.scheduledTimer(withTimeInterval: rotationInterval,
                                     repeats: true) { _ in
            guard !imageURLs.isEmpty else { return }
            currentImageIndex = (currentImageIndex + 1) % imageURLs.count
            loadImageAsync(at: imageURLs[currentImageIndex])
        }
    }

    private func loadImageAsync(at url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let img = NSImage(contentsOf: url) else { return }
            DispatchQueue.main.async {
                currentImage = img
                updateSize(for: img)      // triggers panel resize
            }
        }
    }

    private func updateSize(for image: NSImage) {
        let ratio = image.size.width / max(image.size.height, 1)
        appState.currentImageSize = NSSize(width: fixedHeight * ratio,  // ← no min-width
                                           height: fixedHeight)
    }
}

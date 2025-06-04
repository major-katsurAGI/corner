import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState

    // Image + rotation state ------------------------------------------------
    @State private var imageURLs: [URL] = []
    @State private var currentImageIndex = 0
    @State private var currentImage: NSImage?
    @State private var timer: Timer?
    @State private var rotationInterval: Double = 30        // default 30 s
    // ----------------------------------------------------------------------

    // Hover-fade
    @State private var isHovering = false
    private var fixedHeight: CGFloat { appState.fixedHeight }

    // MARK: body
    var body: some View {
        ZStack {
            //------------------------------------------------ IMAGE ----------
            HStack(spacing: 0) {
                if appState.anchor == .right { Spacer(minLength: 0) }

                imageView()
                    .frame(height: fixedHeight)

                if appState.anchor == .left  { Spacer(minLength: 0) }
            }
            .frame(height: fixedHeight)

            //------------------------------------------------ UI OVERLAY -----
            overlayUI
                .opacity(isHovering || appState.selectedFolder == nil ? 1 : 0)
                .allowsHitTesting(isHovering || appState.selectedFolder == nil)
        }
        .frame(width: appState.currentImageSize?.width ?? 350,
               height: fixedHeight)
        .background(Color.clear)
        .onHover { isHovering = $0 }

        // React to interval change
        .onChange(of: rotationInterval) { _ in restartRotation() }

        // Load images when user picks a folder
        .onChange(of: appState.selectedFolder) { folder in
            if let folder {          // user picked (or restored) a folder
                loadImages(from: folder)
            } else {                 // user clicked “×” ➞ reset to placeholder
                stopRotation()
                imageURLs.removeAll()
                currentImage = nil
                appState.currentImageSize = NSSize(width: 350, height: fixedHeight)
            }
        }
        .onAppear {
            if appState.currentImageSize == nil {
                appState.currentImageSize = NSSize(width: 350, height: fixedHeight)
            }
            
            if let folder = appState.selectedFolder, imageURLs.isEmpty {
                loadImages(from: folder)
            }
        }
    }

    // MARK: - Image / placeholder
    @ViewBuilder
    private func imageView() -> some View {
        if let img = currentImage {
            Image(nsImage: img)
                .resizable()
                .interpolation(.high)
                .aspectRatio(contentMode: .fit)
        } else {
            Text("Select a folder to display images")
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity,
                       alignment: .center)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Overlay UI ----------------------------------------------------
    private var overlayUI: some View {
        VStack {
            //------------------- TOP: anchor button -------------------------
            HStack {
                if appState.anchor == .left {
                    anchorButton
                    Spacer()
                    intervalMenu
                } else {
                    intervalMenu
                    Spacer()
                    anchorButton
                }
            }

            Spacer()

            //------------------- LEFT/RIGHT BUTTONS -------------------------
            HStack(spacing: 4) {
                Button(action: showPreviousImage) {
                    Image(systemName: "chevron.left")
                        .padding(6)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }

                Spacer()

                Button(action: showNextImage) {
                    Image(systemName: "chevron.right")
                        .padding(6)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
            }
            
            Spacer()

            //------------------- BOTTOM-LEFT: folder + interval ------------
            HStack(spacing: 4) {
                folderButton
                if appState.selectedFolder != nil { clearButton }
                Spacer()
            }
        }
        .padding(7)
        .buttonStyle(.plain)
    }

    private var anchorButton: some View {
        Button {
            appState.anchor = appState.anchor == .left ? .right : .left
        } label: {
            Image(systemName: appState.anchor == .left ? "arrow.right" : "arrow.left")
                .padding(6)
                .background(Color.black.opacity(0.5))
                .clipShape(Circle())
        }
    }

    private var folderButton: some View {
        Button { appState.selectFolder?() } label: {
            Image(systemName: "folder")
                .padding(6)
                .background(Color.black.opacity(0.5))
                .clipShape(Circle())
        }
    }
    
    private var clearButton: some View {
        Button { appState.clearSelection() } label: {
            Image(systemName: "xmark.circle")
                .padding(6)
                .background(Color.black.opacity(0.5))
                .clipShape(Circle())
        }
    }

    private var intervalMenu: some View {
        Menu {
            Button("5 seconds")   { setInterval(5)    }
            Button("10 seconds")  { setInterval(10)   }
            Button("30 seconds")  { setInterval(30)   }
            Button("1 minute")    { setInterval(60)   }
            Button("5 minutes")   { setInterval(300)  }
            Button("15 minutes")  { setInterval(900)  }
            Button("1 hour")      { setInterval(3600) }
        } label: {
            Image(systemName: "timer")
                .padding(5)
                .background(Color.black.opacity(0.5))
                .clipShape(Circle())
        }
    }

    // MARK: - Image loading & rotation -------------------------------------
    private func setInterval(_ seconds: Double) {
        rotationInterval = seconds
    }

    private func loadImages(from folder: URL) {
        stopRotation()

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
        stopRotation()

        timer = Timer(timeInterval: rotationInterval, repeats: true) { _ in
            guard !imageURLs.isEmpty else { return }
            currentImageIndex = (currentImageIndex + 1) % imageURLs.count
            loadImageAsync(at: imageURLs[currentImageIndex])
        }
        if let timer { RunLoop.main.add(timer, forMode: .common) }
    }

    private func restartRotation() {
        if timer != nil { startRotation() }
    }

    private func stopRotation() {
        timer?.invalidate()
        timer = nil
    }
    
    private func showPreviousImage() {
        guard !imageURLs.isEmpty else { return }
        currentImageIndex = (currentImageIndex - 1 + imageURLs.count) % imageURLs.count
        loadImageAsync(at: imageURLs[currentImageIndex])
    }

    private func showNextImage() {
        guard !imageURLs.isEmpty else { return }
        currentImageIndex = (currentImageIndex + 1) % imageURLs.count
        loadImageAsync(at: imageURLs[currentImageIndex])
    }


    private func loadImageAsync(at url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let img = NSImage(contentsOf: url) else { return }
            DispatchQueue.main.async {
                currentImage = img
                updateSize(for: img)
            }
        }
    }

    private func updateSize(for image: NSImage) { // REPLACE entire func
        let ratio = image.size.width / max(image.size.height, 1)
        appState.currentImageSize = NSSize(width: appState.fixedHeight * ratio,
                                           height: appState.fixedHeight)
    }
}

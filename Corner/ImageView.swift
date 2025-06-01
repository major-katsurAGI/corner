import SwiftUI

struct ImageView: View {
    let imageURL: URL
    let fixedHeight: CGFloat
    @EnvironmentObject var appState: AppState

    var body: some View {
        if let image = NSImage(contentsOf: imageURL) {
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: fixedHeight)
                .onAppear {
                    let aspectRatio = image.size.width / max(image.size.height, 1)
                    let scaledWidth = fixedHeight * aspectRatio
                    appState.currentImageSize = NSSize(width: max(scaledWidth, 200), height: fixedHeight)
                }
        }
    }
}

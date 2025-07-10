import SwiftUI

struct NetworkImageView<Content: View, Placeholder: View>: View {
    let url: URL?

    @ViewBuilder private let content: (Image) -> Content
    @ViewBuilder private let placeholder: () -> Placeholder

    @StateObject private var imageLoader = ImageLoader()
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let image = imageLoader.image {
                content(Image(uiImage: image))
            } else {
                placeholder()
            }
        }
        .task {
            await imageLoader.loadImage(from: url)
        }
    }
}

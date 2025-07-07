import SwiftUI

struct NetworkImageView<Content: View, Placeholder: View>: View {
    let url: URL?

    @ViewBuilder private let content: (Image) -> Content
    @ViewBuilder private let placeholder: () -> Placeholder

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
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                content(image)
            case .empty, .failure:
                placeholder()
            @unknown default:
                placeholder()
            }
        }
    }
}

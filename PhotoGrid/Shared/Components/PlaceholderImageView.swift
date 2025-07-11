import SwiftUI

struct PlaceholderImageView: View {
    enum Layout {
        static let cornerRadius: CGFloat = 8
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: Layout.cornerRadius)
            .fill(.gray.opacity(0.3))
            .overlay {
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundStyle(.gray)
            }
    }
}

#Preview {
    PlaceholderImageView()
        .frame(width: 60, height: 60)
}

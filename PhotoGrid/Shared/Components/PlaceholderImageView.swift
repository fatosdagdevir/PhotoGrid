import SwiftUI

struct PlaceholderImageView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
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

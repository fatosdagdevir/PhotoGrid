import SwiftUI

struct PhotoListItemView: View {
    let photo: Photo
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            NetworkImageView(
                url: photo.smallImageURL,
                content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                },
                placeholder: {
                    PlaceholderImageView()
                }
            )
            .frame(width: 60, height: 60)
            .clipped()
            .cornerRadius(8)
            
            Text("By \(photo.author)")
                .font(.headline)
                .lineLimit(1)
            
            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .accessibilityLabel("Photo by \(photo.author)")
        .accessibilityHint("Double tap to view photo details, swipe left to remove from favourites")
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    PhotoListItemView(
        photo: .mockPhotos[0],
        onTap: {}
    )
    .padding()
}

import SwiftUI

struct FavouritePhotoItemView: View {
    private enum Layout {
        enum Image {
            static let width: CGFloat = 60
            static let height: CGFloat = 60
            static let cornerRadius: CGFloat = 8
        }
        
        enum Content {
            static let hSpacing: CGFloat = 12
            static let vPadding: CGFloat = 4
        }
    }
    
    let photo: Photo
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: Layout.Content.hSpacing) {
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
            .frame(width: Layout.Image.width, height: Layout.Image.height)
            .clipped()
            .cornerRadius(Layout.Image.cornerRadius)
            
            Text("By \(photo.author)")
                .font(.headline)
                .lineLimit(1)
            
            Spacer()
        }
        .padding(.vertical, Layout.Content.vPadding)
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
    FavouritePhotoItemView(
        photo: .mockPhotos[0],
        onTap: {}
    )
    .padding()
}

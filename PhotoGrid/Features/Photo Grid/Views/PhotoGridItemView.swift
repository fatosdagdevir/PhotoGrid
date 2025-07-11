import SwiftUI

struct PhotoGridItemView: View {
    private enum Layout {
        enum Image {
            static let minWidth: CGFloat = 100
            static let minHeight: CGFloat = 100
            static let cornerRadius: CGFloat = 8
        }
        
        enum FavouriteIndicator {
            static let iconSize: CGFloat = 15
            static let shadowRadius: CGFloat = 2
            static let padding: CGFloat = 8
        }
    }
    
    let photo: Photo
    let isFavourite: Bool
    let onTap: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
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
            .frame(minWidth: Layout.Image.minWidth, minHeight: Layout.Image.minHeight)
            .clipped()
            .cornerRadius(Layout.Image.cornerRadius)
            .onTapGesture {
                onTap()
            }
            .accessibilityLabel(accessibilityLabel)
            .accessibilityHint("Double tap to view photo details")
            .accessibilityAddTraits(.isButton)
            
            favouriteIndicator
        }
    }
    
    private var accessibilityLabel: String {
        let baseLabel = "Photo by \(photo.author)"
        return isFavourite ? "\(baseLabel), marked as favourite" : baseLabel
    }
    
    @ViewBuilder
    private var favouriteIndicator: some View {
        if isFavourite {
            Image(systemName: "heart.fill")
                .font(.system(size: Layout.FavouriteIndicator.iconSize))
                .foregroundStyle(.red)
                .shadow(radius: Layout.FavouriteIndicator.shadowRadius)
                .padding(Layout.FavouriteIndicator.padding)
                .accessibilityHidden(true)
        }
    }
}

#Preview {
    VStack {
        PhotoGridItemView(
            photo: .mockPhotos[0],
            isFavourite: false,
            onTap: {}
        )
        
        PhotoGridItemView(
            photo: .mockPhotos[0],
            isFavourite: true,
            onTap: {}
        )
    }
    .padding()
}

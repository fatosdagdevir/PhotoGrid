import SwiftUI

struct PhotoGridItemView: View {
    let photo: Photo
    let isFavourite: Bool
    let onTap: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            NetworkImageView(
                url: photo.thumbnailURL,
                content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                },
                placeholder: {
                    PlaceholderImageView()
                }
            )
            .frame(minWidth: 100, minHeight: 100)
            .clipped()
            .cornerRadius(8)
            .onTapGesture {
                onTap()
            }
            
            favouriteIndicator
        }
    }
    
    @ViewBuilder
    private var favouriteIndicator: some View {
        if isFavourite {
            Image(systemName: "heart.fill")
                .font(.system(size: 15))
                .foregroundStyle(.red)
                .shadow(radius: 2)
                .padding(8)
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

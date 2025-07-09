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
                    photoPlaceholder
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
    
    @ViewBuilder
    private var photoPlaceholder: some View {
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
    VStack {
        PhotoGridItemView(
            photo: .init(
                id: "1",
                author: "",
                width: 300,
                height: 200,
                url: "",
                downloadUrl: "https://fastly.picsum.photos/id/0/5000/3333.jpg?hmac=_j6ghY5fCfSD6tvtcV74zXivkJSPIfR9B8w34XeQmvU"
            ),
            isFavourite: false,
            onTap: {}
        )
        
        PhotoGridItemView(
            photo: .init(
                id: "1",
                author: "",
                width: 300,
                height: 200,
                url: "",
                downloadUrl: "https://fastly.picsum.photos/id/0/5000/3333.jpg?hmac=_j6ghY5fCfSD6tvtcV74zXivkJSPIfR9B8w34XeQmvU"
            ),
            isFavourite: true,
            onTap: {}
        )
    }
    .padding()
}

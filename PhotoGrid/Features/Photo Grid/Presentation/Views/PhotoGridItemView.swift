import SwiftUI

struct PhotoGridItemView: View {
    let photo: Photo
    
    var body: some View {
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
    PhotoGridItemView(
        photo: .init(
            id: "1",
            author: "",
            width: 300,
            height: 200,
            url: "",
            downloadUrl: "https://fastly.picsum.photos/id/0/5000/3333.jpg?hmac=_j6ghY5fCfSD6tvtcV74zXivkJSPIfR9B8w34XeQmvU"
        )
    )
}

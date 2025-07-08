import SwiftUI

struct PhotoDetailView: View {
    let photo: Photo
    let onDismiss: () -> Void
    
    var body: some View {
        NetworkImageView(
            url: URL(string: photo.downloadUrl),
            content: { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            },
            placeholder: {
                ProgressView()
            }
        )
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                dismissButton
            }
        }
    }
    
    private var dismissButton: some View {
        Button {
            onDismiss()
        } label: {
            Image(systemName: "xmark")
                .frame(width: 30)
                .foregroundColor(.gray)
        }
    }
}

struct PhotoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoDetailView(
            photo: previewPhotos[0],
            onDismiss: {}
        )
    }
}

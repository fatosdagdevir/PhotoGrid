import SwiftUI

struct PhotoDetailView: View {
    private enum Layout {
        enum DismissButton {
            static let width: CGFloat = 30
        }
    }
    
    @StateObject var viewModel: PhotoDetailViewModel
    
    var body: some View {
        NetworkImageView(
            url: viewModel.photo.bigImageURL,
            content: { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            },
            placeholder: {
                ProgressView()
            }
        )
        .accessibilityLabel("Photo by \(viewModel.photo.author)")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                favouriteButton
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                dismissButton
            }
        }
        .task {
            await viewModel.checkFavouriteStatus()
        }
    }
    
    private var dismissButton: some View {
        Button {
            viewModel.dismiss()
        } label: {
            Image(systemName: "xmark")
                .frame(width: Layout.DismissButton.width)
                .foregroundColor(.gray)
        }
        .accessibilityLabel("Close photo")
        .accessibilityHint("Double tap to close")
    }
    
    private var favouriteButton: some View {
        Button {
            Task {
                await viewModel.toggleFavourite()
            }
        } label: {
            Image(systemName: viewModel.isFavourite ? "heart.fill" : "heart")
                .foregroundStyle(viewModel.isFavourite ? .red : .gray)
        }
        .accessibilityLabel(favouriteButtonLabel)
        .accessibilityHint("Double tap to \(viewModel.isFavourite ? "remove from" : "add to") favourites")
    }
    
    private var favouriteButtonLabel: String {
        viewModel.isFavourite ? "Remove from favourites" : "Add to favourites"
    }
}

struct PhotoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PhotoDetailView(
                viewModel: previewPhotoDetailViewModel
            )
        }
    }
}

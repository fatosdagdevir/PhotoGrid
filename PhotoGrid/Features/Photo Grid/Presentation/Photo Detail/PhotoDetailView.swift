import SwiftUI

struct PhotoDetailView: View {
    @ObservedObject var viewModel: PhotoDetailViewModel
    
    var body: some View {
        NetworkImageView(
            url: URL(string: viewModel.photo.downloadUrl),
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
                .frame(width: 30)
                .foregroundColor(.gray)
        }
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

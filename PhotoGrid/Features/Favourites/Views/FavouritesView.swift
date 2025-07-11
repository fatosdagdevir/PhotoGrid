import SwiftUI

struct FavouritesView: View {
    private enum Layout {
        enum EmptyView {
            static let vSpacing: CGFloat = 16
            static let iconSize: CGFloat = 30
        }
    }
    
    enum ViewState: Equatable {
        case loading
        case ready(photos: [Photo])
        case empty
        case error(viewModel: ErrorViewModel)
    }
    
    @ObservedObject var viewModel: FavouritesViewModel
    
    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                ProgressView()
                    .accessibilityLabel("Loading favourite photos")
            case .empty:
                emptyView
            case .ready(let favPhotos):
                photoList(with: favPhotos)
            case .error(let viewModel):
                ErrorView(viewModel: viewModel)
            }
        }
        .onFirstAppear {
            await viewModel.loadFavourites()
        }
    }
    
    @ViewBuilder
    private var emptyView: some View {
        VStack(spacing: Layout.EmptyView.vSpacing) {
            Image(systemName: "heart.fill")
                .imageScale(.large)
                .foregroundStyle(.red)
                .font(.system(size: Layout.EmptyView.iconSize))
            
            Text("Your favourite photos will appear here")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .navigationBarTitleDisplayMode(.automatic)
        .accessibilityLabel("No favourite photos")
        .accessibilityHint("Photos you mark as favourite will appear here")
    }
    
    @ViewBuilder
    private func photoList(with photos: [Photo]) -> some View {
        List {
            ForEach(photos) { photo in
                FavouritePhotoItemView(
                    photo: photo,
                    onTap: {
                        viewModel.presentPhotoDetail(photo: photo)
                    }
                )
                .listRowSeparator(.hidden)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let photo = photos[index]
                    Task {
                        await viewModel.removeFromFavourites(photo: photo)
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Favourite Photos")
        .navigationBarTitleDisplayMode(.automatic)
        .accessibilityLabel("Favourite photos list with \(photos.count) photos")
        .accessibilityHint("Swipe left on a photo to remove it from favourites")
    }
}

struct FavouritesView_Previews: PreviewProvider {
    static var previews: some View {
        
        // MARK: Ready
        NavigationView {
            FavouritesView(
                viewModel: previewFavouritesViewModel(
                    state: .ready(photos: Photo.mockPhotos)
                )
            )
        }
        .previewDisplayName("Ready")
        
        // MARK: Loading
        NavigationView {
            FavouritesView(
                viewModel: previewFavouritesViewModel(state: .loading)
            )
        }
        .previewDisplayName("Loading")
        
        // MARK: Empty
        NavigationView {
            FavouritesView(
                viewModel: previewFavouritesViewModel(state: .empty)
            )
        }
        .previewDisplayName("Empty")
        
        // MARK: Error
        NavigationView {
            FavouritesView(
                viewModel: previewFavouritesViewModel(
                    state: .error(viewModel: previewErrorViewModel)
                )
            )
        }
        .previewDisplayName("Error")
    }
}


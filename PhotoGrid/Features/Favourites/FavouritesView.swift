import SwiftUI

struct FavouritesView: View {
    enum ViewState {
        case loading
        case ready(photos: [Photo])
        case empty
        case error
    }
    
    @ObservedObject var viewModel: FavouritesViewModel
    
    let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 8)
    ]
    
    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                ProgressView()
            case .empty:
                emptyView
            case .ready(let favPhotos):
                photoGrid(with: favPhotos)
            case .error:
                Text("Opps!")
            }
        }
        .task {
            await viewModel.loadFavourites()
        }
    }
    
    @ViewBuilder
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.fill")
                .imageScale(.large)
                .foregroundStyle(.red)
                .font(.system(size: 30))
            
            Text("Your favourite photos will appear here")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .navigationBarTitleDisplayMode(.automatic)
    }
    
    @ViewBuilder
    private func photoGrid(with photos: [Photo]) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(photos) { photo in
                    PhotoGridItemView(
                        photo: photo,
                        isFavourite: true,
                        onTap: {
                            viewModel.presentPhotoDetail(photo: photo)
                        }
                    )
                }
            }
            .padding(8)
        }
    }
}

struct FavouritesView_Previews: PreviewProvider {
    static var previews: some View {
        
        // MARK: Ready
        NavigationView {
            FavouritesView(
                viewModel: previewFavouritesViewModel(
                    state: .ready(photos: previewPhotos)
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
    }
}


import SwiftUI

struct FavouritesView: View {
    enum ViewState {
        case loading
        case ready(photos: [Photo])
        case empty
        case error
    }
    
    @ObservedObject var viewModel: FavouritesViewModel
    
    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                ProgressView()
            case .empty:
                emptyView
            case .ready(let favPhotos):
                photoList(with: favPhotos)
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
    private func photoList(with photos: [Photo]) -> some View {
        List {
            ForEach(photos) { photo in
                PhotoListItemView(
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
    }
}


import SwiftUI

struct PhotoGridView: View {
    enum ViewState: Equatable {
        case loading
        case ready(photos: [Photo])
        case empty
        case error(viewModel: ErrorViewModel)
    }
    
    private enum Layout {
        enum Grid {
            static let vSpacing: CGFloat = 4
            static let hSpacing: CGFloat = 8
            static let minimumItemWidth: CGFloat = 100
        }
        
        enum EmptyView {
            static let vSpacing: CGFloat = 4
            static let iconSize: CGFloat = 30
        }
        
        enum Content {
            static let padding: CGFloat = 8
        }
    
        static let hPadding: CGFloat = 16
    }
    
    @ObservedObject var viewModel: PhotoGridViewModel
    
    let columns = [
        GridItem(.adaptive(minimum: Layout.Grid.minimumItemWidth), spacing: Layout.Grid.hSpacing)
    ]
    
    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                ProgressView()
                    .accessibilityLabel("Loading photos")
            case .ready(let photos):
                photoGrid(with: photos)
            case .empty:
                emptyView
            case .error(let viewModel):
                ErrorView(viewModel: viewModel)
            }
        }
        .onFirstAppear {
            await viewModel.fetchPhotoGrid()
        }
    }
    
    @ViewBuilder
    private func photoGrid(with photos: [Photo]) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Layout.Grid.vSpacing) {
                ForEach(photos) { photo in
                    PhotoGridItemView(
                        photo: photo,
                        isFavourite: viewModel.isFavourite(photo.id),
                        onTap: {
                            viewModel.presentPhotoDetail(photo: photo)
                        }
                    )
                }
            }
            .padding(Layout.Content.padding)
        }
        .accessibilityLabel("Photo grid with \(photos.count) photos")
        .accessibilityHint("Scroll to browse photos, double tap on a photo to view details")
    }
    
    @ViewBuilder
    private var emptyView: some View {
        VStack(spacing: Layout.EmptyView.vSpacing) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: Layout.EmptyView.iconSize))
                .foregroundStyle(.gray)
            Text("No photos available")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .accessibilityLabel("No photos available")
    }
}

struct PhotoGridView_Previews: PreviewProvider {
    static var previews: some View {
        
        // MARK: Ready
        NavigationView {
            PhotoGridView(
                viewModel: previewGridViewModel(
                    state: .ready(photos: Photo.mockPhotos)
                )
            )
        }
        .previewDisplayName("Ready")
        
        // MARK: Loading
        NavigationView {
            PhotoGridView(
                viewModel: previewGridViewModel(state: .loading)
            )
        }
        .previewDisplayName("Loading")
        
        // MARK: Empty
        NavigationView {
            PhotoGridView(
                viewModel: previewGridViewModel(state: .empty)
            )
        }
        .previewDisplayName("Empty")
        
        // MARK: Error
        NavigationView {
            PhotoGridView(
                viewModel: previewGridViewModel(
                    state: .error(viewModel: previewErrorViewModel)
                )
            )
        }
        .previewDisplayName("Error")
    }
}

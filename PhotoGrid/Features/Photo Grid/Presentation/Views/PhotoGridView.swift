import SwiftUI

struct PhotoGridView: View {
    enum ViewState {
        case loading
        case ready(photos: [Photo])
        case empty
        case error
    }
    
    @ObservedObject var viewModel: PhotoGridViewModel
    
    let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 8)
    ]
    
    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                ProgressView()
            case .ready(let photos):
                photoGrid(with: photos)
            case .empty:
                emptyView
            case .error:
                Text("Oppss!!")
            }
        }
        .task {
            await viewModel.fetchPhotoGrid()
        }
    }
    
    @ViewBuilder
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 30))
                .foregroundStyle(.gray)
            Text("No photos available")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    @ViewBuilder
    private func photoGrid(with photos: [Photo]) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(photos) { photo in
                    PhotoGridItemView(
                        photo: photo,
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

struct PhotoGridView_Previews: PreviewProvider {
    static var previews: some View {
        
        // MARK: Ready
        NavigationView {
            PhotoGridView(
                viewModel: previewGridViewModel(
                    state: .ready(photos: previewPhotos)
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
    }
}

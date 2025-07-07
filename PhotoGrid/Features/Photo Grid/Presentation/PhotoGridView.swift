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
                content(with: photos)
            case .empty:
                Text("There is no photo..")
            case .error:
                Text("Oppss!!")
            }
        }
        .task {
            await viewModel.fetchPhotoGrid()
        }
    }
    
    @ViewBuilder
    private func content(with photos: [Photo]) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(photos) { photo in
                    NetworkImageView(
                        url: URL(string: photo.downloadUrl),
                        content: { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        },
                        placeholder: {
                            photoPlaceholder
                        })
                    .frame(minWidth: 100, minHeight: 100)
                    .clipped()
                    .cornerRadius(8)
                }
            }
            .padding(8)
        }
    }
    
    @ViewBuilder
    private var photoPlaceholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.3))
            .overlay(
                Image(systemName: "photo")
                    .foregroundColor(.gray)
            )
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

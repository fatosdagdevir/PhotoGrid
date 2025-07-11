import SwiftUI

struct PhotoGridCoordinator: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var navigator: Navigator
    private let photoService: PhotoService
    @StateObject private var viewModel: PhotoGridViewModel
    private let favouritesManager: FavouritesManaging
    
    init(
        navigator: Navigator,
        photoService: PhotoService,
        favouritesManager: FavouritesManaging
    ) {
        self.navigator = navigator
        self.photoService = photoService
        self.favouritesManager = favouritesManager
        
        self._viewModel = StateObject(wrappedValue: PhotoGridViewModel(
            navigator: navigator,
            photoService: photoService,
            favouritesManager: favouritesManager
        ))
    }
    
    var body: some View {
        PhotoGridView(viewModel: viewModel)
            .sheet(item: $navigator.sheet) { destination in
                NavigationStack {
                    switch destination {
                    case .photoDetail(let photo):
                        createPhotoDetailView(with: photo)
                    }
                }
            }
    }
    
    // MARK: - Private Functions
    private func createPhotoDetailView(with photo: Photo) -> PhotoDetailView {
        let viewModel = PhotoDetailViewModel(
            navigator: navigator,
            favouritesManager: favouritesManager,
            photo: photo
        )
        return PhotoDetailView(viewModel: viewModel)
    }
}

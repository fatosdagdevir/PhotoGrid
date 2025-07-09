import SwiftUI

struct PhotoGridCoordinator: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var navigator: Navigator
    @StateObject private var photoService: PhotoService
    @StateObject private var viewModel: PhotoGridViewModel
    private let favouritesManager: FavouritesManaging
    
    init(
        navigator: Navigator,
        favouritesManager: FavouritesManaging
    ) {
        self.navigator = navigator
        self.favouritesManager = favouritesManager
        
        let photoProvider = PhotoProvider()
        let photoService = PhotoService(photoProvider: photoProvider)
        self._photoService = StateObject(wrappedValue: photoService)
        
        self._viewModel = StateObject(wrappedValue: PhotoGridViewModel(
            navigator: navigator,
            photoService: photoService
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

import SwiftUI

struct FavouritesCoordinator: View {
    @ObservedObject var navigator: Navigator
    @StateObject private var viewModel: FavouritesViewModel
    private let photoService: PhotoService
    private let favouritesManager: FavouritesManaging
    
    init(
        navigator: Navigator,
        photoService: PhotoService,
        favouritesManager: FavouritesManaging
    ) {
        self.navigator = navigator
        self.photoService = photoService
        self.favouritesManager = favouritesManager
        
        self._viewModel = StateObject(wrappedValue: FavouritesViewModel(
            navigator: navigator,
            photoService: photoService,
            favouritesManager: favouritesManager
        ))
    }
    
    var body: some View {
        FavouritesView(viewModel: viewModel)
            .sheet(item: $navigator.sheet) { destination in
                NavigationStack {
                    switch destination {
                    case .photoDetail(let photo):
                        PhotoDetailView(viewModel: createPhotoDetailViewModel(with: photo))
                    }
                }
            }
    }
    
    private func createPhotoDetailViewModel(with photo: Photo) -> PhotoDetailViewModel {
        return PhotoDetailViewModel(
            navigator: navigator,
            favouritesManager: favouritesManager,
            photo: photo
        )
    }
}

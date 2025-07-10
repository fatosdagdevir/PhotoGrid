import SwiftUI
import SwiftData

extension PreviewProvider {
    static func previewFavouritesViewModel(state: FavouritesView.ViewState) -> FavouritesViewModel {
        let mockState: MockPhotoProvider.MockState
        let mockFavouritesManager = MockFavouritesManager()
        
        switch state {
        case .loading:
            mockState = .loading
        case .ready:
            mockState = .ready
            // Set up the favourites manager with some mock photos as favourites
            mockFavouritesManager.setFavourites(Photo.mockPhotos.prefix(5).map { $0.id })
        case .empty:
            mockState = .ready // We want photos available but none favourited
        case .error:
            mockState = .error
        }
        
        let photoProvider = MockPhotoProvider(state: mockState)
        let photoService = PhotoService(photoProvider: photoProvider)
        
        return FavouritesViewModel(
            navigator: Navigator(),
            photoService: photoService,
            favouritesManager: mockFavouritesManager
        )
    }
}

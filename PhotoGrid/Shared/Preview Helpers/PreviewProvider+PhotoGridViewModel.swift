import SwiftUI

extension PreviewProvider {
    static func previewGridViewModel(state: PhotoGridView.ViewState) -> PhotoGridViewModel {
        let mockState: MockPhotoProvider.MockState
        
        switch state {
        case .loading:
            mockState = .loading
        case .ready:
            mockState = .ready
        case .empty:
            mockState = .empty
        case .error:
            mockState = .error
        }
        
        let photoProvider = MockPhotoProvider(state: mockState)
        let photoService = PhotoService(photoProvider: photoProvider)
        let mockFavouritesManager = MockFavouritesManager()
        
        return PhotoGridViewModel(
            navigator: Navigator(),
            photoService: photoService,
            favouritesManager: mockFavouritesManager
        )
    }
}

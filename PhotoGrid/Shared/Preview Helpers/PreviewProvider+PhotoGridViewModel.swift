import SwiftUI

extension PreviewProvider {
    static func previewGridViewModel(state: PhotoGridView.ViewState) -> PhotoGridViewModel {
        let photoProvider = PhotoProvider()
        let photoService = PhotoService(photoProvider: photoProvider)
        let mockFavouritesManager = MockFavouritesManager()
        let viewModel = PhotoGridViewModel(
            navigator: Navigator(),
            photoService: photoService,
            favouritesManager: mockFavouritesManager
        )
        viewModel.viewState = state
        return viewModel
    }
}

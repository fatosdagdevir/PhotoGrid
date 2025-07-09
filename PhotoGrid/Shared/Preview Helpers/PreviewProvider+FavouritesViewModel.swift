import SwiftUI
import SwiftData

extension PreviewProvider {
    static func previewFavouritesViewModel(state: FavouritesView.ViewState) -> FavouritesViewModel {
        let photoProvider = PhotoProvider()
        let photoService = PhotoService(photoProvider: photoProvider)
        let viewModel = FavouritesViewModel(
            navigator: Navigator(),
            photoService: photoService,
            favouritesManager: MockFavouritesManager()
        )
        viewModel.viewState = state
        return viewModel
    }
}

import SwiftUI
import SwiftData

extension PreviewProvider {
    static func previewFavouritesViewModel(state: FavouritesView.ViewState) -> FavouritesViewModel {
        let tempContext = try! ModelContainer(for: FavouritePhoto.self).mainContext
        let mockManager = FavouritesManager(modelContext: tempContext)
        let photoProvider = PhotoProvider()
        let photoService = PhotoService(photoProvider: photoProvider)
        let viewModel = FavouritesViewModel(
            navigator: Navigator(),
            photoService: photoService,
            favouritesManager: mockManager
        )
        viewModel.viewState = state
        return viewModel
    }
}

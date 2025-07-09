import SwiftUI
import SwiftData

extension PreviewProvider {
    static var previewPhotoDetailViewModel: PhotoDetailViewModel {
        let tempContext = try! ModelContainer(for: FavouritePhoto.self).mainContext
        let mockManager = FavouritesManager(modelContext: tempContext)
        return PhotoDetailViewModel(
            navigator: Navigator(),
            favouritesManager: mockManager,
            photo: previewPhotos[0]
        )
    }
}

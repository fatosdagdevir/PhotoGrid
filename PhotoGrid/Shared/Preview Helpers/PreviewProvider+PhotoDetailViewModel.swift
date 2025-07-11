import SwiftUI
import SwiftData

extension PreviewProvider {
    static var previewPhotoDetailViewModel: PhotoDetailViewModel {
        return PhotoDetailViewModel(
            navigator: Navigator(),
            favouritesManager: MockFavouritesManager(),
            photo: .mockPhotos[0]
        )
    }
}

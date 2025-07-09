import Foundation

@MainActor
final class FavouritesViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var viewState: FavouritesView.ViewState = .loading
    
    // MARK: - Private Properties
    private let navigator: Navigating
    private let photoService: PhotoService
    private let favouritesManager: FavouritesManaging
    
    init(
        navigator: Navigating,
        photoService: PhotoService,
        favouritesManager: FavouritesManaging
    ) {
        self.navigator = navigator
        self.photoService = photoService
        self.favouritesManager = favouritesManager
    }
    
    // MARK: - Public Functions
    func loadFavourites() async {
        do {
            let photos = try await photoService.fetchPhotos()
            let filteredFavouritePhotos = filterFavouritePhotos(with: photos)
            
            guard !filteredFavouritePhotos.isEmpty else {
                viewState = .empty
                return
            }
            
            viewState = .ready(photos: filteredFavouritePhotos)
        } catch {
            viewState = .error
        }
    }
    
    func isFavourite(_ photoId: String) -> Bool {
        favouritesManager.isFavourite(photoId)
    }
    
    func presentPhotoDetail(photo: Photo) {
        navigator.presentSheet(.photoDetail(photo: photo))
    }
    
    func removeFromFavourites(photo: Photo) async {
        await favouritesManager.removeFromFavourites(photo.id)
        await loadFavourites()
    }
    
    // MARK: - Private Functions
    private func filterFavouritePhotos(with photos: [Photo]) -> [Photo] {
        let favouriteIds = Set(favouritesManager.getAllFavouriteIds())
        return photos.filter { favouriteIds.contains($0.id) }
    }
}

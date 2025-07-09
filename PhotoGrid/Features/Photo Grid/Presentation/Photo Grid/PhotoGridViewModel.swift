import Foundation

@MainActor
final class PhotoGridViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var viewState: PhotoGridView.ViewState = .loading
    @Published var favouriteStatuses: [String: Bool] = [:]
    
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
    func fetchPhotoGrid() async {
        do {
            let photos = try await photoService.fetchPhotos()
            
            guard !photos.isEmpty else {
                viewState = .empty
                return
            }
            
            viewState = .ready(photos: photos)
            await loadFavouriteStatuses(for: photos)
        } catch {
            viewState = .error
        }
    }
    
    func presentPhotoDetail(photo: Photo) {
        navigator.presentSheet(.photoDetail(photo: photo))
    }
    
    func isFavourite(_ photoId: String) -> Bool {
        favouriteStatuses[photoId] ?? false
    }
  
    // MARK: - Private Functions
    private func loadFavouriteStatuses(for photos: [Photo]) async {
        for photo in photos {
            let isFav = await favouritesManager.isFavourite(photo.id)
            favouriteStatuses[photo.id] = isFav
        }
    }
}

import Foundation

@MainActor
final class PhotoDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isFavourite: Bool = false
    @Published var photo: Photo
    
    // MARK: - Private Properties
    private let navigator: Navigating
    private let favouritesManager: FavouritesManaging
    
    init(
        navigator: Navigating,
        favouritesManager: FavouritesManaging,
        photo: Photo
    ) {
        self.navigator = navigator
        self.favouritesManager = favouritesManager
        self.photo = photo
    }
    
    func checkFavouriteStatus() async {
        isFavourite = await favouritesManager.isFavourite(photo.id)
    }
    
    func dismiss() {
        navigator.dismissSheet()
    }
    
    func toggleFavourite() async {
        if isFavourite {
            await favouritesManager.removeFromFavourites(photo.id)
        } else {
            await favouritesManager.addToFavourites(photo.id)
        }
        
        isFavourite.toggle()
    }
}

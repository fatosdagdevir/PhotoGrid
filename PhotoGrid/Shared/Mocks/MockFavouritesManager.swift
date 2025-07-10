import Foundation
import Combine

// MARK: - Mock Favourites Manager
@MainActor
class MockFavouritesManager: FavouritesManaging {
    private let favouriteStatusSubject = PassthroughSubject<String, Never>()
    private var favouriteIds: Set<String> = []
    
    var favouriteStatusPublisher: AnyPublisher<String, Never> {
        favouriteStatusSubject.eraseToAnyPublisher()
    }
    
    func addToFavourites(_ photoId: String) async {
        favouriteIds.insert(photoId)
        favouriteStatusSubject.send(photoId)
    }
    
    func removeFromFavourites(_ photoId: String) async {
        favouriteIds.remove(photoId)
        favouriteStatusSubject.send(photoId)
    }
    
    func isFavourite(_ photoId: String) async -> Bool {
        favouriteIds.contains(photoId)
    }
    
    func getAllFavouriteIds() async -> Set<String> {
        favouriteIds
    }
    
    // MARK: - Preview Helpers
    func setFavourites(_ photoIds: [String]) {
        favouriteIds = Set(photoIds)
    }
}

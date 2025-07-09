import Foundation
import Combine

// MARK: - Mock Favourites Manager
@MainActor
class MockFavouritesManager: FavouritesManaging {
    private let favouriteStatusSubject = PassthroughSubject<String, Never>()
    
    var favouriteStatusPublisher: AnyPublisher<String, Never> {
        favouriteStatusSubject.eraseToAnyPublisher()
    }
    
    func addToFavourites(_ photoId: String) async {
        favouriteStatusSubject.send(photoId)
    }
    
    func removeFromFavourites(_ photoId: String) async {
        favouriteStatusSubject.send(photoId)
    }
    
    func isFavourite(_ photoId: String) async -> Bool { false }
    
    func getAllFavouriteIds() async -> Set<String> { [] }
}

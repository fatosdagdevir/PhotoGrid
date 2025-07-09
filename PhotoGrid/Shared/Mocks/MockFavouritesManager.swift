import Foundation

// MARK: - Mock Favourites Manager
class MockFavouritesManager: FavouritesManaging {
    func addToFavourites(_ photoId: String) async {}
    func removeFromFavourites(_ photoId: String) async {}
    func isFavourite(_ photoId: String) -> Bool { false }
    func getAllFavouriteIds() -> Set<String> { [] }
}

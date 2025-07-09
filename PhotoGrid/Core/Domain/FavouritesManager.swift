import Foundation
import SwiftData

protocol FavouritesManaging {
    func addToFavourites(_ photoId: String) async
    func removeFromFavourites(_ photoId: String) async
    func isFavourite(_ photoId: String) async -> Bool
    func getAllFavouriteIds() async -> Set<String>
}

@MainActor
final class FavouritesManager: FavouritesManaging {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func addToFavourites(_ photoId: String) async {
        let favourite = FavouritePhoto(photoId: photoId)
        modelContext.insert(favourite)
        try? modelContext.save()
    }
    
    func removeFromFavourites(_ photoId: String) async {
        let descriptor = FetchDescriptor<FavouritePhoto>(
            predicate: #Predicate { $0.photoId == photoId }
        )
        let favourites = try? modelContext.fetch(descriptor)
        favourites?.forEach { modelContext.delete($0) }
        try? modelContext.save()
    }
    
    func isFavourite(_ photoId: String) async -> Bool {
        let descriptor = FetchDescriptor<FavouritePhoto>(
            predicate: #Predicate { $0.photoId == photoId }
        )
        return (try? modelContext.fetchCount(descriptor)) ?? 0 > 0
    }
    
    func getAllFavouriteIds() async -> Set<String> {
        let favourites = (try? modelContext.fetch(FetchDescriptor<FavouritePhoto>())) ?? []
        return Set(favourites.map(\.photoId))
    }
}

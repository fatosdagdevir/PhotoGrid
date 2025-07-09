import Foundation
import SwiftData
import Combine

@MainActor
protocol FavouritesManaging {
    func addToFavourites(_ photoId: String) async
    func removeFromFavourites(_ photoId: String) async
    func isFavourite(_ photoId: String) async -> Bool
    func getAllFavouriteIds() async -> Set<String>
    var favouriteStatusPublisher: AnyPublisher<String, Never> { get }
}

@MainActor
final class FavouritesManager: FavouritesManaging {
    private let modelContext: ModelContext
    private let favouriteStatusSubject = PassthroughSubject<String, Never>()
    
    var favouriteStatusPublisher: AnyPublisher<String, Never> {
        favouriteStatusSubject.eraseToAnyPublisher()
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func addToFavourites(_ photoId: String) async {
        let favourite = FavouritePhoto(photoId: photoId)
        modelContext.insert(favourite)
        try? modelContext.save()
        favouriteStatusSubject.send(photoId)
    }
    
    func removeFromFavourites(_ photoId: String) async {
        let descriptor = FetchDescriptor<FavouritePhoto>(
            predicate: #Predicate { $0.photoId == photoId }
        )
        let favourites = try? modelContext.fetch(descriptor)
        favourites?.forEach { modelContext.delete($0) }
        try? modelContext.save()
        favouriteStatusSubject.send(photoId)
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

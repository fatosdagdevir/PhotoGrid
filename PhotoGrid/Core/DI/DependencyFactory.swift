import Foundation
import SwiftData

// MARK: - Dependency Factory Protocol
@MainActor
protocol DependencyFactoryProtocol {
    func makePhotoService() -> PhotoServicing
    func makePhotoProvider() -> PhotoProviding
    func makeFavouritesManager() -> FavouritesManaging
    func makeNavigator() -> Navigator
}

// MARK: - Dependency Factory
@MainActor
final class DependencyFactory: DependencyFactoryProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext? = nil) {
        if let modelContext = modelContext {
            self.modelContext = modelContext
        } else {
            guard let container = try? ModelContainer(for: FavouritePhoto.self) else {
                fatalError("Failed to initialize ModelContainer for FavouritePhoto")
            }
            self.modelContext = ModelContext(container)
        }
    }
    
    func makePhotoService() -> PhotoServicing {
        let photoProvider = makePhotoProvider()
        return PhotoService(photoProvider: photoProvider)
    }
    
    func makePhotoProvider() -> PhotoProviding {
        return PhotoProvider()
    }
    
    func makeFavouritesManager() -> FavouritesManaging {
        return FavouritesManager(modelContext: modelContext)
    }
    
    func makeNavigator() -> Navigator {
        return Navigator()
    }
}

@testable import PhotoGrid

// MARK: - Mock Dependency Factory for Testing
@MainActor
final class MockDependencyFactory: DependencyFactoryProtocol {
    // MARK: - Mock Services
    let mockPhotoService = MockPhotoService()
    let mockPhotoProvider = MockPhotoProvider()
    let mockFavouritesManager = MockFavouritesManager()
    let mockNavigator = MockNavigator()
    
    // MARK: - Factory Methods
    func makePhotoService() -> PhotoServicing {
        return mockPhotoService
    }
    
    func makePhotoProvider() -> PhotoProviding {
        return mockPhotoProvider
    }
    
    func makeFavouritesManager() -> FavouritesManaging {
        return mockFavouritesManager
    }
    
    func makeNavigator() -> Navigator {
        return Navigator()
    }
    
    // MARK: - Testing Helper Methods
    func makeMockNavigator() -> MockNavigator {
        return mockNavigator
    }
    
    // MARK: - Configuration Methods for Testing
    func configureMockPhotoService(with photos: [Photo]) {
        mockPhotoService.mockResult = .success(photos)
    }
    
    func configureMockPhotoService(with error: Error) {
        mockPhotoService.mockResult = .failure(error)
    }
    
    func configureMockFavourites(with photoIds: [String]) {
        mockFavouritesManager.setFavourites(photoIds)
    }
    
    func reset() {
        mockPhotoService.mockResult = .success([])
        mockFavouritesManager.setFavourites([])
    }
}

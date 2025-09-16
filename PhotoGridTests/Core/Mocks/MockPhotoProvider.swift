import Foundation
import Networking
@testable import PhotoGrid

final class MockPhotoProvider: PhotoProviding, @unchecked Sendable {
    var mockPhotos: [Photo] = []
    var shouldThrowError = false
    var mockError: Error = PhotoProviderError.networkError
    var fetchPhotoGridCallCount = 0
    
    func fetchPhotoGrid() async throws -> [Photo] {
        fetchPhotoGridCallCount += 1
        
        if shouldThrowError {
            throw mockError
        }
        
        return mockPhotos
    }
}

enum PhotoProviderError: Error, Equatable {
    case networkError
}

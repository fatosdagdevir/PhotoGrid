import Foundation
import Networking
@testable import PhotoGrid

final class MockPhotoService: PhotoServicing {
    var mockResult: Result<[Photo], Error> = .success([])
    
    func fetchPhotos() async throws -> [Photo] {
        switch mockResult {
        case .success(let photos):
            return photos
        case .failure(let error):
            throw error
        }
    }
    
    func refreshPhotos() async throws -> [Photo] {
        return try await fetchPhotos()
    }
} 

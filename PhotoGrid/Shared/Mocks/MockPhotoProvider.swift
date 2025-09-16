import Foundation

final class MockPhotoProvider: PhotoProviding, @unchecked Sendable {
    private let state: MockState
    
    enum MockState {
        case loading
        case ready
        case empty
        case error
    }
    
    init(state: MockState = .ready) {
        self.state = state
    }
    
    func fetchPhotoGrid() async throws -> [Photo] {
        switch state {
        case .loading:
            try await Task.sleep(nanoseconds: 4_000_000_000) // 4 seconds
            return Photo.mockPhotos
            
        case .ready:
            return Photo.mockPhotos
            
        case .empty:
            return []
            
        case .error:
            throw URLError(.badServerResponse)
        }
    }
} 

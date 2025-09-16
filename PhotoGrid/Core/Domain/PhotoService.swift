import Foundation

protocol PhotoServicing: Sendable {
    func fetchPhotos() async throws -> [Photo]
    func refreshPhotos() async throws -> [Photo]
}

actor PhotoService: PhotoServicing {
    enum LoadState {
        case idle
        case loading
        case loaded
    }
    
    // MARK: - Private Properties
    private let photoProvider: PhotoProviding
    private var photos: [Photo] = []
    private var state: LoadState = .idle
    
    init(photoProvider: PhotoProviding) {
        self.photoProvider = photoProvider
    }
    
    func fetchPhotos() async throws -> [Photo] {
        guard case .idle = state else {
            return photos
        }

        state = .loading
        let result = try await photoProvider.fetchPhotoGrid()
        self.photos = result
        state = .loaded
        return result
    }
    
    func refreshPhotos() async throws -> [Photo] {
        state = .idle
        return try await fetchPhotos()
    }
}

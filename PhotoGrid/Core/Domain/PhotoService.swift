import Foundation

@MainActor
final class PhotoService: ObservableObject {
    enum LoadState {
        case idle
        case loading
        case loaded
    }
    
    // MARK: - Published Properties
    @Published private(set) var photos: [Photo] = []
    @Published private(set) var state: LoadState = .idle
    
    // MARK: - Private Properties
    private let photoProvider: PhotoProviding
    private var hasLoaded = false
    
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
    
    func fetchPhotoGrid() async throws -> [Photo] {
        try await photoProvider.fetchPhotoGrid()
    }
    
    func refreshPhotos() async throws -> [Photo] {
        state = .idle
        return try await fetchPhotos()
    }
}

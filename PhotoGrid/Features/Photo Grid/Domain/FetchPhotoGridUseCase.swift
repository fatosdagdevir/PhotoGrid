import Foundation

struct FetchPhotoGridUseCase {
    private let photoProvider: PhotoProviding
    
    init(photoProvider: PhotoProviding) {
        self.photoProvider = photoProvider
    }
    
    func fetchPhotoGrid() async throws -> [Photo] {
        try await photoProvider.fetchPhotoGrid()
    }
}

import Foundation

@MainActor
final class PhotoGridViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var viewState: PhotoGridView.ViewState = .loading
    
    // MARK: - Private Properties
    private let navigator: Navigating
    private let photoService: PhotoService
    
    init(
        navigator: Navigating,
        photoService: PhotoService
    ) {
        self.navigator = navigator
        self.photoService = photoService
    }
    
    // MARK: - Public Functions
    func fetchPhotoGrid() async {
        do {
            let photos = try await photoService.fetchPhotos()
            
            guard !photos.isEmpty else {
                viewState = .empty
                return
            }
            
            viewState = .ready(photos: photos)
        } catch {
            viewState = .error
        }
    }
    
    func presentPhotoDetail(photo: Photo) {
        navigator.presentSheet(.photoDetail(photo: photo))
    }
}

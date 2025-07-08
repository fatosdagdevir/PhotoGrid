import Foundation
import Networking

@MainActor
final class PhotoGridViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var viewState: PhotoGridView.ViewState = .loading
    
    // MARK: - Private Properties
    private let navigator: Navigating
    private let fetchPhotoGridUseCase: FetchPhotoGridUseCase
    
    init(
        navigator: Navigating,
        fetchPhotoGridUseCase: FetchPhotoGridUseCase
    ) {
        self.navigator = navigator
        self.fetchPhotoGridUseCase = fetchPhotoGridUseCase
    }
    
    // MARK: - Public Functions
    func fetchPhotoGrid() async {
        do {
            let photos = try await fetchPhotoGridUseCase.fetchPhotoGrid()
            
            guard !photos.isEmpty else {
                viewState = .empty
                return
            }
            
            viewState = .ready(photos: photos)
        } catch {
            //TODO: Handle Error
            viewState = .error
        }
    }
    
    func presentPhotoDetail(photo: Photo) {
        navigator.presentSheet(.photoDetail(photo: photo))
    }
}

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
    
    func fetchPhotoGrid() async {
        do {
            let photos = try await fetchPhotoGridUseCase.fetchPhotoGrid()
            viewState = .ready(photos: photos)
        } catch {
           print("\(error)")
        }
    }
}

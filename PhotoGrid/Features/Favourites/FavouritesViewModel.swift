import Foundation
import Combine

@MainActor
final class FavouritesViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var viewState: FavouritesView.ViewState = .loading
    
    // MARK: - Private Properties
    private let navigator: Navigating
    private let photoService: PhotoServicing
    private let favouritesManager: FavouritesManaging
    private var cancellables = Set<AnyCancellable>()
    
    init(
        navigator: Navigating,
        photoService: PhotoServicing,
        favouritesManager: FavouritesManaging
    ) {
        self.navigator = navigator
        self.photoService = photoService
        self.favouritesManager = favouritesManager
        
        setupFavouriteStatusSubscription()
    }
    
    // MARK: - Public Functions
    func loadFavourites() async {
        do {
            let photos = try await photoService.fetchPhotos()
            let filteredFavouritePhotos = await filterFavouritePhotos(with: photos)
            
            guard !filteredFavouritePhotos.isEmpty else {
                viewState = .empty
                return
            }
            
            viewState = .ready(photos: filteredFavouritePhotos)
        } catch {
            handleError(error)
        }
    }
    
    func presentPhotoDetail(photo: Photo) {
        navigator.presentSheet(.photoDetail(photo: photo))
    }
    
    func removeFromFavourites(photo: Photo) async {
        await favouritesManager.removeFromFavourites(photo.id)
    }
    
    // MARK: - Private Functions
    private func setupFavouriteStatusSubscription() {
        favouritesManager.favouriteStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                
                Task {
                    await self.loadFavourites()
                }
            }
            .store(in: &cancellables)
    }
    
    private func filterFavouritePhotos(with photos: [Photo]) async -> [Photo] {
        let favouriteIds = await favouritesManager.getAllFavouriteIds()
        return photos.filter { favouriteIds.contains($0.id) }
    }
    
    private func refresh() async {
        viewState = .loading
        
        await loadFavourites()
    }
    
    private func handleError(_ error: Error) {
        viewState = .error(
            viewModel: ErrorViewModel(
                error: error,
                action: { @MainActor [weak self] in
                    await self?.refresh()
                }
            )
        )
    }
}

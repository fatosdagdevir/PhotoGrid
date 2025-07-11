import Foundation
import Combine

@MainActor
final class PhotoGridViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var viewState: PhotoGridView.ViewState = .loading
    @Published var favouriteStatuses: [String: Bool] = [:]
    
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
    func fetchPhotoGrid() async {
        do {
            let photos = try await photoService.fetchPhotos()
            
            guard !photos.isEmpty else {
                viewState = .empty
                return
            }
            
            viewState = .ready(photos: photos)
            await loadFavouriteStatuses(for: photos)
        } catch {
            handleError(error)
        }
    }
    
    func presentPhotoDetail(photo: Photo) {
        navigator.presentSheet(.photoDetail(photo: photo))
    }
    
    func isFavourite(_ photoId: String) -> Bool {
        favouriteStatuses[photoId] ?? false
    }
    
    // MARK: - Private Functions
    private func setupFavouriteStatusSubscription() {
        favouritesManager.favouriteStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] photoId in
                Task {
                    await self?.updateFavouriteStatus(for: photoId)
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateFavouriteStatus(for photoId: String) async {
        let isFav = await favouritesManager.isFavourite(photoId)
        favouriteStatuses[photoId] = isFav
    }
    
    private func loadFavouriteStatuses(for photos: [Photo]) async {
        await withTaskGroup(of: (String, Bool).self) { group in
            for photo in photos {
                group.addTask { [weak self] in
                    guard let self else { return (photo.id, false) }
                    
                    let isFav = await favouritesManager.isFavourite(photo.id)
                    return (photo.id, isFav)
                }
            }

            for await (id, isFav) in group {
                favouriteStatuses[id] = isFav
            }
        }
    }
    
    private func refresh() async {
        viewState = .loading
        
        await fetchPhotoGrid()
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

import XCTest
import Combine
@testable import PhotoGrid

@MainActor
final class PhotoGridViewModelTests: XCTestCase {
    var sut: PhotoGridViewModel!
    var mockNavigator: MockNavigator!
    var mockPhotoService: MockPhotoService!
    var mockFavouritesManager: MockFavouritesManager!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() async throws {
        mockNavigator = MockNavigator()
        mockPhotoService = MockPhotoService()
        mockFavouritesManager = MockFavouritesManager()
        cancellables = []
        
        sut = PhotoGridViewModel(
            navigator: mockNavigator,
            photoService: mockPhotoService,
            favouritesManager: mockFavouritesManager
        )
    }
    
    override func tearDown() async throws {
        cancellables = nil
        sut = nil
        mockNavigator = nil
        mockPhotoService = nil
        mockFavouritesManager = nil
    }
    
    func test_init_setsInitialStateToLoading() {
        XCTAssertEqual(sut.viewState, .loading)
        XCTAssertTrue(sut.favouriteStatuses.isEmpty)
    }
    
    func test_fetchPhotoGrid_successWithPhotos_setsReadyState() async {
        // Given
        let mockPhotos = Photo.mockPhotos
        mockPhotoService.mockResult = .success(mockPhotos)
        
        // When
        await sut.fetchPhotoGrid()
        
        // Then
        XCTAssertEqual(sut.viewState, .ready(photos: mockPhotos))
    }
    
    func test_fetchPhotoGrid_successWithEmptyPhotos_setsEmptyState() async {
        // Given
        mockPhotoService.mockResult = .success([])
        
        // When
        await sut.fetchPhotoGrid()
        
        // Then
        XCTAssertEqual(sut.viewState, .empty)
    }
    
    func test_fetchPhotoGrid_failure_setsErrorState() async {
        // Given
        let mockError = URLError(.badServerResponse)
        mockPhotoService.mockResult = .failure(mockError)
        
        // When
        await sut.fetchPhotoGrid()
        
        // Then
        switch sut.viewState {
        case .error(let errorViewModel):
            XCTAssertEqual(errorViewModel.error as? URLError, mockError)
        default:
            XCTFail("Expected error state, got \(sut.viewState)")
        }
    }
    
    func test_fetchPhotoGrid_loadsFavouriteStatusesForPhotos() async {
        // Given
        let mockPhotos = Photo.mockPhotos
        mockPhotoService.mockResult = .success(mockPhotos)
        mockFavouritesManager.setFavourites([mockPhotos[0].id, mockPhotos[2].id])
        
        // When
        await sut.fetchPhotoGrid()
        
        // Then
        XCTAssertTrue(sut.isFavourite(mockPhotos[0].id))
        XCTAssertFalse(sut.isFavourite(mockPhotos[1].id))
        XCTAssertTrue(sut.isFavourite(mockPhotos[2].id))
    }
    
    func test_isFavourite_returnsCorrectStatus() {
        // Given
        let photoId = "test-photo"
        sut.favouriteStatuses[photoId] = true
        
        // When & Then
        XCTAssertTrue(sut.isFavourite(photoId))
        
        // Given
        sut.favouriteStatuses[photoId] = false
        
        // When & Then
        XCTAssertFalse(sut.isFavourite(photoId))
        
        // Given - unknown photo
        // When & Then
        XCTAssertFalse(sut.isFavourite("unknown-photo"))
    }
    
    func test_presentPhotoDetail_callsNavigatorWithCorrectPhoto() {
        // Given
        let photo = Photo.mockPhotos[0]
        
        // When
        sut.presentPhotoDetail(photo: photo)
        
        // Then
        XCTAssertEqual(mockNavigator.presentedSheet, .photoDetail(photo: photo))
    }
    
    func test_favouriteStatusSubscription_updatesStatusOnChanges() async {
        // Given
        let photoId = "subscription-test-photo"
        var publishedPhotoIds: [String] = []
        
        mockFavouritesManager.favouriteStatusPublisher
            .sink { photoId in
                publishedPhotoIds.append(photoId)
            }
            .store(in: &cancellables)
        
        // When - Add to favourites
        await mockFavouritesManager.addToFavourites(photoId)
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        XCTAssertEqual(publishedPhotoIds.count, 1)
        XCTAssertEqual(publishedPhotoIds.first, photoId)
        XCTAssertTrue(sut.isFavourite(photoId))
        
        // When - Remove from favourites
        await mockFavouritesManager.removeFromFavourites(photoId)
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        XCTAssertEqual(publishedPhotoIds.count, 2)
        XCTAssertFalse(sut.isFavourite(photoId))
    }
    
    func test_handleError_createsErrorViewModelWithRetryAction() async {
        // Given
        let mockError = URLError(.networkConnectionLost)
        mockPhotoService.mockResult = .failure(mockError)
        
        // When
        await sut.fetchPhotoGrid()
        
        // Then
        switch sut.viewState {
        case .error(let errorViewModel):
            XCTAssertEqual(errorViewModel.error as? URLError, mockError)
            // Test that retry action works
            mockPhotoService.mockResult = .success(Photo.mockPhotos)
            await errorViewModel.action()
            // Should attempt to refresh
            XCTAssertEqual(sut.viewState, .ready(photos: Photo.mockPhotos))
        default:
            XCTFail("Expected error state")
        }
    }
}

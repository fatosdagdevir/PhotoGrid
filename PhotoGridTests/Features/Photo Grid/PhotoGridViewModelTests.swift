import XCTest
import Combine
@testable import PhotoGrid

@MainActor
final class PhotoGridViewModelTests: XCTestCase {
    var sut: PhotoGridViewModel!
    var mockFactory: MockDependencyFactory!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() async throws {
        mockFactory = MockDependencyFactory()
        cancellables = []
        
        sut = PhotoGridViewModel(
            navigator: mockFactory.makeNavigator(),
            photoService: mockFactory.makePhotoService(),
            favouritesManager: mockFactory.makeFavouritesManager()
        )
    }
    
    override func tearDown() async throws {
        cancellables = nil
        sut = nil
        mockFactory = nil
    }
    
    func test_init_setsInitialStateToLoading() {
        XCTAssertEqual(sut.viewState, .loading)
        XCTAssertTrue(sut.favouriteStatuses.isEmpty)
    }
    
    func test_fetchPhotoGrid_successWithPhotos_setsReadyState() async {
        // Given
        let mockPhotos = Photo.mockPhotos
        mockFactory.configureMockPhotoService(with: mockPhotos)
        
        // When
        await sut.fetchPhotoGrid()
        
        // Then
        XCTAssertEqual(sut.viewState, .ready(photos: mockPhotos))
    }
    
    func test_fetchPhotoGrid_successWithEmptyPhotos_setsEmptyState() async {
        // Given
        mockFactory.configureMockPhotoService(with: [])
        
        // When
        await sut.fetchPhotoGrid()
        
        // Then
        XCTAssertEqual(sut.viewState, .empty)
    }
    
    func test_fetchPhotoGrid_failure_setsErrorState() async {
        // Given
        let mockError = URLError(.badServerResponse)
        mockFactory.configureMockPhotoService(with: mockError)
        
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
        mockFactory.configureMockPhotoService(with: mockPhotos)
        mockFactory.configureMockFavourites(with: [mockPhotos[0].id, mockPhotos[2].id])
        
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
        let mockNavigator = mockFactory.makeMockNavigator()
        
        // Create a new view model with the same mock navigator for this test
        let testViewModel = PhotoGridViewModel(
            navigator: mockNavigator,
            photoService: mockFactory.makePhotoService(),
            favouritesManager: mockFactory.makeFavouritesManager()
        )
        
        // When
        testViewModel.presentPhotoDetail(photo: photo)
        
        // Then
        XCTAssertEqual(mockNavigator.presentedSheet, .photoDetail(photo: photo))
    }
    
    func test_favouriteStatusSubscription_updatesStatusOnChanges() async {
        // Given
        let photoId = "subscription-test-photo"
        sut.favouriteStatuses[photoId] = false
        
        let addExpectation = XCTestExpectation(description: "Photo added to favourites")
        let removeExpectation = XCTestExpectation(description: "Photo removed from favourites")
        
        // Monitor the ViewModel's state changes
        let cancellable = sut.$favouriteStatuses
            .dropFirst() // Skip initial value
            .sink { statuses in
                if statuses[photoId] == true {
                    addExpectation.fulfill()
                } else if statuses[photoId] == false {
                    removeExpectation.fulfill()
                }
            }
        
        defer { cancellable.cancel() }
        
        // When - Add to favourites
        await mockFactory.mockFavouritesManager.addToFavourites(photoId)
        await fulfillment(of: [addExpectation], timeout: 1.0)
        
        // Then
        XCTAssertTrue(sut.isFavourite(photoId))
        
        // When - Remove from favourites
        await mockFactory.mockFavouritesManager.removeFromFavourites(photoId)
        await fulfillment(of: [removeExpectation], timeout: 1.0)
        
        // Then
        XCTAssertFalse(sut.isFavourite(photoId))
    }
    
    func test_handleError_createsErrorViewModelWithRetryAction() async {
        // Given
        let mockError = URLError(.networkConnectionLost)
        mockFactory.configureMockPhotoService(with: mockError)
        
        // When
        await sut.fetchPhotoGrid()
        
        // Then
        switch sut.viewState {
        case .error(let errorViewModel):
            XCTAssertEqual(errorViewModel.error as? URLError, mockError)
            // Test that retry action works
            mockFactory.configureMockPhotoService(with: Photo.mockPhotos)
            await errorViewModel.action()
            // Should attempt to refresh
            XCTAssertEqual(sut.viewState, .ready(photos: Photo.mockPhotos))
        default:
            XCTFail("Expected error state")
        }
    }
}

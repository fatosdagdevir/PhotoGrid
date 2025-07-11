import XCTest
import Combine
import Networking
@testable import PhotoGrid

@MainActor
final class FavouritesViewModelTests: XCTestCase {
    var sut: FavouritesViewModel!
    var mockNavigator: MockNavigator!
    var mockPhotoService: MockPhotoService!
    var mockFavouritesManager: MockFavouritesManager!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() async throws {
        mockNavigator = MockNavigator()
        mockPhotoService = MockPhotoService()
        mockFavouritesManager = MockFavouritesManager()
        cancellables = []
        
        sut = FavouritesViewModel(
            navigator: mockNavigator,
            photoService: mockPhotoService,
            favouritesManager: mockFavouritesManager
        )
    }
    
    override func tearDown() async throws {
        cancellables.removeAll()
        sut = nil
        mockNavigator = nil
        mockPhotoService = nil
        mockFavouritesManager = nil
    }
    
    func test_init_setsInitialState() {
        // Then
        XCTAssertEqual(sut.viewState, .loading)
    }
    
    func test_init_setsUpFavouriteStatusSubscription() {
        // Given
        let expectation = XCTestExpectation(description: "Subscription is set up")
        var receivedPhotoId: String?
        
        mockFavouritesManager.favouriteStatusPublisher
            .sink { photoId in
                receivedPhotoId = photoId
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        Task {
            await mockFavouritesManager.addToFavourites("test-photo")
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedPhotoId, "test-photo")
    }
    
    func test_loadFavourites_withFavouritePhotos_setsReadyStateAndFiltersCorrectly() async {
        // Given
        let testPhotos = Photo.mockPhotos
        let favouriteIds = [testPhotos[0].id, testPhotos[2].id]
        mockPhotoService.mockResult = .success(testPhotos)
        mockFavouritesManager.setFavourites(favouriteIds)
        
        // When
        await sut.loadFavourites()
        
        // Then
        if case .ready(let photos) = sut.viewState {
            XCTAssertEqual(photos.count, 2)
            XCTAssertTrue(photos.contains { $0.id == testPhotos[0].id })
            XCTAssertTrue(photos.contains { $0.id == testPhotos[2].id })
            XCTAssertFalse(photos.contains { $0.id == testPhotos[1].id })
        } else {
            XCTFail("Expected .ready state, got \(sut.viewState)")
        }
    }
    
    func test_loadFavourites_withEmptyResult_setsEmptyState() async {
        // Test scenario 1: No photos at all
        mockPhotoService.mockResult = .success([])
        mockFavouritesManager.setFavourites(["some-id"])
        
        await sut.loadFavourites()
        XCTAssertEqual(sut.viewState, .empty)
        
        // Test scenario 2: Has photos but no favourites
        let testPhotos = Photo.mockPhotos
        mockPhotoService.mockResult = .success(testPhotos)
        mockFavouritesManager.setFavourites([])
        
        await sut.loadFavourites()
        XCTAssertEqual(sut.viewState, .empty)
    }
    
    func test_loadFavourites_withError_setsErrorState() async {
        // Given
        let testError = NetworkError.invalidStatus(500)
        mockPhotoService.mockResult = .failure(testError)
        
        // When
        await sut.loadFavourites()
        
        // Then
        if case .error(let errorViewModel) = sut.viewState {
            XCTAssertEqual(errorViewModel.error.localizedDescription, testError.localizedDescription)
        } else {
            XCTFail("Expected .error state, got \(sut.viewState)")
        }
    }

    func test_presentPhotoDetail_callsNavigator() {
        // Given
        let testPhoto = Photo.mockPhotos[0]
        
        // When
        sut.presentPhotoDetail(photo: testPhoto)
        
        // Then
        XCTAssertEqual(mockNavigator.presentedSheet, .photoDetail(photo: testPhoto))
    }
    
    func test_removeFromFavourites_callsFavouritesManager() async {
        // Given
        let testPhoto = Photo.mockPhotos[0]
        
        // When
        await sut.removeFromFavourites(photo: testPhoto)
        
        // Then
        let isFavourite = await mockFavouritesManager.isFavourite(testPhoto.id)
        XCTAssertFalse(isFavourite)
    }
    
    func test_favouriteStatusSubscription_worksEndToEnd() async {
        // Given
        let testPhotos = Photo.mockPhotos
        let favouriteIds = [testPhotos[0].id]
        mockPhotoService.mockResult = .success(testPhotos)
        mockFavouritesManager.setFavourites(favouriteIds)
        
        // When - Initial load
        await sut.loadFavourites()
        
        // Verify initial state
        if case .ready(let initialPhotos) = sut.viewState {
            XCTAssertEqual(initialPhotos.count, 1)
            XCTAssertEqual(initialPhotos[0].id, testPhotos[0].id)
        } else {
            XCTFail("Expected initial state to be .ready, got \(sut.viewState)")
        }
        
        // Set up expectation for subscription refresh
        let expectation = XCTestExpectation(description: "View state updates on subscription")
        
        // Monitor view state changes after initial load
        sut.$viewState
            .dropFirst() // Skip the current state
            .sink { state in
                if case .ready(let photos) = state {
                    // Check if the new photo was added
                    if photos.count == 2 && photos.contains(where: { $0.id == testPhotos[1].id }) {
                        expectation.fulfill()
                    }
                }
            }
            .store(in: &cancellables)
        
        // When - Trigger subscription by adding a new favourite
        await mockFavouritesManager.addToFavourites(testPhotos[1].id)
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Verify final state
        if case .ready(let finalPhotos) = sut.viewState {
            XCTAssertEqual(finalPhotos.count, 2)
            XCTAssertTrue(finalPhotos.contains { $0.id == testPhotos[0].id })
            XCTAssertTrue(finalPhotos.contains { $0.id == testPhotos[1].id })
        } else {
            XCTFail("Expected final state to be .ready, got \(sut.viewState)")
        }
    }
    
    func test_handleError_setsErrorStateWithRetryAction() async {
        // Given
        let testError = NetworkError.invalidStatus(500)
        mockPhotoService.mockResult = .failure(testError)
        
        // When
        await sut.loadFavourites() // This will trigger handleError internally
        
        // Then
        if case .error(let errorViewModel) = sut.viewState {
            XCTAssertEqual(errorViewModel.error.localizedDescription, testError.localizedDescription)
            
            // Test that retry action works
            let retryExpectation = XCTestExpectation(description: "Retry action triggers refresh")
            
            // Monitor state changes during retry
            sut.$viewState
                .dropFirst() // Skip current error state
                .sink { state in
                    if case .loading = state {
                        retryExpectation.fulfill()
                    }
                }
                .store(in: &cancellables)
            
            // Trigger retry
            await errorViewModel.action()
            
            await fulfillment(of: [retryExpectation], timeout: 1.0)
        } else {
            XCTFail("Expected .error state, got \(sut.viewState)")
        }
    }
    
    func test_fullWorkflow_addRemoveFavourites() async {
        // Given
        let testPhotos = Photo.mockPhotos
        mockPhotoService.mockResult = .success(testPhotos)
        mockFavouritesManager.setFavourites([])
        
        // When - Initial load (no favourites)
        await sut.loadFavourites()
        
        // Then - Should be empty
        XCTAssertEqual(sut.viewState, .empty)
        
        // When - Add a favourite
        await mockFavouritesManager.addToFavourites(testPhotos[0].id)
        
        // Wait for subscription to trigger refresh
        let expectation = XCTestExpectation(description: "State updates after adding favourite")
        sut.$viewState
            .dropFirst() // Skip current empty state
            .sink { state in
                if case .ready = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Then - Should have one photo
        if case .ready(let photos) = sut.viewState {
            XCTAssertEqual(photos.count, 1)
            XCTAssertEqual(photos[0].id, testPhotos[0].id)
        } else {
            XCTFail("Expected .ready state, got \(sut.viewState)")
        }
        
        // When - Remove the favourite
        await sut.removeFromFavourites(photo: testPhotos[0])
        
        // Wait for subscription to trigger refresh
        let removeExpectation = XCTestExpectation(description: "State updates after removing favourite")
        sut.$viewState
            .dropFirst() // Skip current ready state
            .sink { state in
                if case .empty = state {
                    removeExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        await fulfillment(of: [removeExpectation], timeout: 2.0)
        
        // Then - Should be empty again
        XCTAssertEqual(sut.viewState, .empty)
    }
}

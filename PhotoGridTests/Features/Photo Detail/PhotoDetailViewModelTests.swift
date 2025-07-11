import XCTest
import Combine
@testable import PhotoGrid

@MainActor
final class PhotoDetailViewModelTests: XCTestCase {
    var sut: PhotoDetailViewModel!
    var mockNavigator: MockNavigator!
    var mockFavouritesManager: MockFavouritesManager!
    var testPhoto: Photo!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() async throws {
        mockNavigator = MockNavigator()
        mockFavouritesManager = MockFavouritesManager()
        testPhoto = Photo.mockPhotos[0]
        cancellables = []
        
        sut = PhotoDetailViewModel(
            navigator: mockNavigator,
            favouritesManager: mockFavouritesManager,
            photo: testPhoto
        )
    }
    
    override func tearDown() async throws {
        cancellables = nil
        sut = nil
        mockNavigator = nil
        mockFavouritesManager = nil
        testPhoto = nil
    }
    
    func test_init_setsCorrectInitialState() {
        // Then
        XCTAssertEqual(sut.photo, testPhoto)
        XCTAssertFalse(sut.isFavourite)
        XCTAssertEqual(mockNavigator.dismissSheetCallCount, 0)
    }
    
    func test_checkFavouriteStatus_whenPhotoIsFavourite_setsIsFavouriteToTrue() async {
        // Given
        mockFavouritesManager.setFavourites([testPhoto.id])
        
        // When
        await sut.checkFavouriteStatus()
        
        // Then
        XCTAssertTrue(sut.isFavourite)
    }
    
    func test_checkFavouriteStatus_whenPhotoIsNotInFavourites_setsIsFavouriteToFalse() async {
        // Given
        mockFavouritesManager.setFavourites(["other-photo-id"])
        
        // When
        await sut.checkFavouriteStatus()
        
        // Then
        XCTAssertFalse(sut.isFavourite)
    }
    
    func test_toggleFavourite_togglesStateCorrectly() async {
        // Given
        sut.isFavourite = false
        mockFavouritesManager.setFavourites([])
        
        // When - First toggle (add to favourites)
        await sut.toggleFavourite()
        
        // Then
        XCTAssertTrue(sut.isFavourite)
        let isFavourite1 = await mockFavouritesManager.isFavourite(testPhoto.id)
        XCTAssertTrue(isFavourite1)
        
        // When - Second toggle (remove from favourites)
        await sut.toggleFavourite()
        
        // Then
        XCTAssertFalse(sut.isFavourite)
        let isFavourite2 = await mockFavouritesManager.isFavourite(testPhoto.id)
        XCTAssertFalse(isFavourite2)
    }
    
    func test_dismiss_callsNavigatorDismissSheet() {
        // Given
        XCTAssertEqual(mockNavigator.dismissSheetCallCount, 0)
        
        // When
        sut.dismiss()
        
        // Then
        XCTAssertEqual(mockNavigator.dismissSheetCallCount, 1)
    }
    
    func test_fullWorkflow_checkStatusThenToggle() async {
        // Given
        mockFavouritesManager.setFavourites([])
        
        // When - Check initial status
        await sut.checkFavouriteStatus()
        
        // Then
        XCTAssertFalse(sut.isFavourite)
        
        // When - Toggle to add to favourites
        await sut.toggleFavourite()
        
        // Then
        XCTAssertTrue(sut.isFavourite)
        let isFavourite = await mockFavouritesManager.isFavourite(testPhoto.id)
        XCTAssertTrue(isFavourite)
        
        // When - Check status again
        await sut.checkFavouriteStatus()
        
        // Then
        XCTAssertTrue(sut.isFavourite)
    }
}

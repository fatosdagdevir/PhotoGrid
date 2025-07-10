import XCTest
import SwiftData
import Combine
@testable import PhotoGrid

@MainActor
final class FavouritesManagerTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    var sut: FavouritesManager!
    var cancellables: Set<AnyCancellable>!

    override func setUp() async throws {
        let schema = Schema([FavouritePhoto.self])
        container = try ModelContainer(for: schema, configurations: [ModelConfiguration(isStoredInMemoryOnly: true)])
        context = ModelContext(container)
        sut = FavouritesManager(modelContext: context)
        cancellables = []
    }

    override func tearDown() async throws {
        cancellables = nil
        sut = nil
        context = nil
        container = nil
    }

    // MARK: - Add to Favourites Tests
    func test_addToFavourites_createsFavouriteInDatabase() async {
        let photoId = "test-photo-1"
        
        // Initially not a favourite
        let initiallyFavourite = await sut.isFavourite(photoId)
        XCTAssertFalse(initiallyFavourite)
        
        // Add to favourites
        await sut.addToFavourites(photoId)
        
        // Should now be a favourite
        let isNowFavourite = await sut.isFavourite(photoId)
        XCTAssertTrue(isNowFavourite)
    }
    
    func test_addToFavourites_multiplePhotos_worksCorrectly() async {
        let photoIds = ["photo-1", "photo-2", "photo-3"]
        
        // Add multiple photos
        for photoId in photoIds {
            await sut.addToFavourites(photoId)
        }
        
        // All should be favourites
        for photoId in photoIds {
            let isFavourite = await sut.isFavourite(photoId)
            XCTAssertTrue(isFavourite)
        }
    }
    
    func test_addToFavourites_duplicatePhoto_isIgnored() async {
        let photoId = "duplicate-photo"
        
        // Add same photo twice
        await sut.addToFavourites(photoId)
        await sut.addToFavourites(photoId)
        
        // Should still be a favourite
        let isFavourite = await sut.isFavourite(photoId)
        XCTAssertTrue(isFavourite)
    }

    func test_removeFromFavourites_removesFavouriteFromDatabase() async {
        let photoId = "test-photo-2"
        
        // Add to favourites first
        await sut.addToFavourites(photoId)
        let isFavouriteAfterAdd = await sut.isFavourite(photoId)
        XCTAssertTrue(isFavouriteAfterAdd)
        
        // Remove from favourites
        await sut.removeFromFavourites(photoId)
        
        // Should no longer be a favourite
        let isFavouriteAfterRemove = await sut.isFavourite(photoId)
        XCTAssertFalse(isFavouriteAfterRemove)
    }
    
    func test_removeFromFavourites_nonExistentPhoto_doesNothing() async {
        let photoId = "non-existent-photo"
        
        // Try to remove a photo that was never added
        await sut.removeFromFavourites(photoId)
        
        // Should not be a favourite
        let isFavourite = await sut.isFavourite(photoId)
        XCTAssertFalse(isFavourite)
    }
    
    func test_removeFromFavourites_multiplePhotos_worksCorrectly() async {
        let photoIds = ["photo-a", "photo-b", "photo-c"]
        
        // Add multiple photos
        for photoId in photoIds {
            await sut.addToFavourites(photoId)
        }
        
        // Remove one photo
        await sut.removeFromFavourites("photo-b")
        
        // Check remaining favourites
        let photoAIsFavourite = await sut.isFavourite("photo-a")
        let photoBIsFavourite = await sut.isFavourite("photo-b")
        let photoCIsFavourite = await sut.isFavourite("photo-c")
        
        XCTAssertTrue(photoAIsFavourite)
        XCTAssertFalse(photoBIsFavourite)
        XCTAssertTrue(photoCIsFavourite)
    }
    
    func test_getAllFavouriteIds_emptyDatabase_returnsEmptySet() async {
        let allIds = await sut.getAllFavouriteIds()
        XCTAssertTrue(allIds.isEmpty)
    }
    
    func test_getAllFavouriteIds_withFavourites_returnsCorrectIds() async {
        let photoIds = ["photo-x", "photo-y", "photo-z"]
        
        // Add favourites
        for photoId in photoIds {
            await sut.addToFavourites(photoId)
        }
        
        // Get all favourite IDs
        let allIds = await sut.getAllFavouriteIds()
        
        // Should contain all added IDs
        XCTAssertEqual(allIds.count, 3)
        for photoId in photoIds {
            XCTAssertTrue(allIds.contains(photoId))
        }
    }
    
    func test_getAllFavouriteIds_afterRemoving_returnsUpdatedIds() async {
        let photoIds = ["photo-1", "photo-2", "photo-3"]
        
        // Add all photos
        for photoId in photoIds {
            await sut.addToFavourites(photoId)
        }
        
        // Remove one photo
        await sut.removeFromFavourites("photo-2")
        
        // Get all favourite IDs
        let allIds = await sut.getAllFavouriteIds()
        
        // Should only contain remaining IDs
        XCTAssertEqual(allIds.count, 2)
        XCTAssertTrue(allIds.contains("photo-1"))
        XCTAssertFalse(allIds.contains("photo-2"))
        XCTAssertTrue(allIds.contains("photo-3"))
    }
    
    func test_getAllFavouriteIds_duplicateIds_returnsUniqueIds() async {
        let photoId = "duplicate-photo"
        
        // Add same photo multiple times (though this shouldn't happen in practice)
        await sut.addToFavourites(photoId)
        await sut.addToFavourites(photoId)
        await sut.addToFavourites(photoId)
        
        let allIds = await sut.getAllFavouriteIds()
        
        // Should only appear once
        XCTAssertEqual(allIds.count, 1)
        XCTAssertTrue(allIds.contains(photoId))
    }

    func test_favouriteStatusPublisher_publishesOnAdd() async {
        let photoId = "publisher-photo"
        var publishedPhotoId: String?
        
        sut.favouriteStatusPublisher
            .sink { photoId in
                publishedPhotoId = photoId
            }
            .store(in: &cancellables)
        
        await sut.addToFavourites(photoId)
        
        XCTAssertEqual(publishedPhotoId, photoId)
    }
    
    func test_favouriteStatusPublisher_publishesOnRemove() async {
        let photoId = "publisher-photo-remove"
        var publishedPhotoId: String?
        
        sut.favouriteStatusPublisher
            .sink { photoId in
                publishedPhotoId = photoId
            }
            .store(in: &cancellables)
        
        await sut.addToFavourites(photoId)
        publishedPhotoId = nil
        
        await sut.removeFromFavourites(photoId)
        
        XCTAssertEqual(publishedPhotoId, photoId)
    }
    
    func test_favouriteStatusPublisher_publishesMultipleEvents() async {
        var publishedPhotoIds: [String] = []
        
        sut.favouriteStatusPublisher
            .sink { photoId in
                publishedPhotoIds.append(photoId)
            }
            .store(in: &cancellables)
        
        // Perform multiple operations
        await sut.addToFavourites("photo-1")
        await sut.addToFavourites("photo-2")
        await sut.removeFromFavourites("photo-1")
        await sut.addToFavourites("photo-3")
        
        // Should have published for each operation
        XCTAssertEqual(publishedPhotoIds.count, 4)
        XCTAssertEqual(publishedPhotoIds[0], "photo-1")
        XCTAssertEqual(publishedPhotoIds[1], "photo-2")
        XCTAssertEqual(publishedPhotoIds[2], "photo-1")
        XCTAssertEqual(publishedPhotoIds[3], "photo-3")
    }
    
    func test_completeWorkflow_addRemoveCheck() async {
        let photoId = "workflow-photo"
        
        // Initial state
        let initiallyFavourite = await sut.isFavourite(photoId)
        let initialAllIds = await sut.getAllFavouriteIds()
        
        XCTAssertFalse(initiallyFavourite)
        XCTAssertTrue(initialAllIds.isEmpty)
        
        // Add to favourites
        await sut.addToFavourites(photoId)
        let isFavouriteAfterAdd = await sut.isFavourite(photoId)
        let allIdsAfterAdd = await sut.getAllFavouriteIds()
        
        XCTAssertTrue(isFavouriteAfterAdd)
        XCTAssertEqual(allIdsAfterAdd.count, 1)
        XCTAssertTrue(allIdsAfterAdd.contains(photoId))
        
        // Remove from favourites
        await sut.removeFromFavourites(photoId)
        let isFavouriteAfterRemove = await sut.isFavourite(photoId)
        let allIdsAfterRemove = await sut.getAllFavouriteIds()
        
        XCTAssertFalse(isFavouriteAfterRemove)
        XCTAssertTrue(allIdsAfterRemove.isEmpty)
    }
}

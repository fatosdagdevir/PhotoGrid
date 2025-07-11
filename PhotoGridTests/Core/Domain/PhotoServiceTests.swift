import XCTest
@testable import PhotoGrid

final class PhotoServiceTests: XCTestCase {
    private var sut: PhotoService!
    private var mockPhotoProvider: MockPhotoProvider!
    
    override func setUp() async throws {
        mockPhotoProvider = MockPhotoProvider()
        sut = PhotoService(photoProvider: mockPhotoProvider)
    }
    
    override func tearDown() async throws {
        sut = nil
        mockPhotoProvider = nil
    }
    
    func test_fetchPhotos_whenIdle_fetchesFromProvider() async throws {
        // Given
        let expectedPhotos = [
            Photo(id: "1", author: "Author 1", width: 100, height: 100, url: "url1", downloadUrl: "download1"),
            Photo(id: "2", author: "Author 2", width: 200, height: 200, url: "url2", downloadUrl: "download2")
        ]
        mockPhotoProvider.mockPhotos = expectedPhotos
        
        // When
        let result = try await sut.fetchPhotos()
        
        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].id, "1")
        XCTAssertEqual(result[1].id, "2")
        XCTAssertEqual(mockPhotoProvider.fetchPhotoGridCallCount, 1)
    }
    
    func test_fetchPhotos_whenLoaded_returnsCachedPhotos() async throws {
        // Given
        let initialPhotos = [
            Photo(id: "1", author: "Author 1", width: 100, height: 100, url: "url1", downloadUrl: "download1")
        ]
        mockPhotoProvider.mockPhotos = initialPhotos
        
        // First fetch to set state to loaded
        _ = try await sut.fetchPhotos()
        
        // Change provider response to simulate different data
        mockPhotoProvider.mockPhotos = [
            Photo(id: "2", author: "Author 2", width: 200, height: 200, url: "url2", downloadUrl: "download2")
        ]
        
        // When - fetch again while in loaded state
        let result = try await sut.fetchPhotos()
        
        // Then - should return cached photos, not call provider again
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].id, "1")
        XCTAssertEqual(mockPhotoProvider.fetchPhotoGridCallCount, 1)
    }
    
    func test_fetchPhotos_whenProviderThrows_propagatesError() async {
        // Given
        mockPhotoProvider.shouldThrowError = true
        mockPhotoProvider.mockError = PhotoProviderError.networkError
        
        // When & Then
        do {
            _ = try await sut.fetchPhotos()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? PhotoProviderError, .networkError)
        }
    }
    
    func test_fetchPhotos_whenProviderReturnsEmptyArray_returnsEmptyArray() async throws {
        // Given
        mockPhotoProvider.mockPhotos = []
        
        // When
        let result = try await sut.fetchPhotos()
        
        // Then
        XCTAssertTrue(result.isEmpty)
        XCTAssertEqual(mockPhotoProvider.fetchPhotoGridCallCount, 1)
    }
    
    func test_refreshPhotos_resetsStateToIdle() async throws {
        // Given
        let initialPhotos = [
            Photo(id: "1", author: "Author 1", width: 100, height: 100, url: "url1", downloadUrl: "download1")
        ]
        mockPhotoProvider.mockPhotos = initialPhotos
        
        // First fetch to set state to loaded
        _ = try await sut.fetchPhotos()
        
        let newPhotos = [
            Photo(id: "2", author: "Author 2", width: 200, height: 200, url: "url2", downloadUrl: "download2"),
            Photo(id: "3", author: "Author 3", width: 300, height: 300, url: "url3", downloadUrl: "download3")
        ]
        mockPhotoProvider.mockPhotos = newPhotos
        
        // When
        let result = try await sut.refreshPhotos()
        
        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].id, "2")
        XCTAssertEqual(result[1].id, "3")
        XCTAssertEqual(mockPhotoProvider.fetchPhotoGridCallCount, 2)
    }

    func test_completeWorkflow_fetchThenRefresh() async throws {
        // Given
        let initialPhotos = [
            Photo(id: "1", author: "Author 1", width: 100, height: 100, url: "url1", downloadUrl: "download1")
        ]
        mockPhotoProvider.mockPhotos = initialPhotos
        
        // When - First fetch
        let firstResult = try await sut.fetchPhotos()
        
        // Then
        XCTAssertEqual(firstResult.count, 1)
        XCTAssertEqual(firstResult[0].id, "1")
        
        // Given - New data
        let newPhotos = [
            Photo(id: "2", author: "Author 2", width: 200, height: 200, url: "url2", downloadUrl: "download2"),
            Photo(id: "3", author: "Author 3", width: 300, height: 300, url: "url3", downloadUrl: "download3")
        ]
        mockPhotoProvider.mockPhotos = newPhotos
        
        // When - Refresh
        let refreshResult = try await sut.refreshPhotos()
        
        // Then
        XCTAssertEqual(refreshResult.count, 2)
        XCTAssertEqual(refreshResult[0].id, "2")
        XCTAssertEqual(refreshResult[1].id, "3")
        
        // When - Fetch again (should return cached data)
        let cachedResult = try await sut.fetchPhotos()
        
        // Then
        XCTAssertEqual(cachedResult.count, 2)
        XCTAssertEqual(cachedResult[0].id, "2")
        XCTAssertEqual(cachedResult[1].id, "3")
        XCTAssertEqual(mockPhotoProvider.fetchPhotoGridCallCount, 2)
    }
}

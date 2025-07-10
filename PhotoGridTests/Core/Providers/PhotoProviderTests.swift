import XCTest
import Networking
@testable import PhotoGrid

@MainActor
final class PhotoProviderTests: XCTestCase {
    private var sut: PhotoProvider!
    private var mockNetwork: MockNetwork!
    
    override func setUp() {
        super.setUp()
        mockNetwork = MockNetwork()
        sut = PhotoProvider(network: mockNetwork)
    }
    
    override func tearDown() {
        sut = nil
        mockNetwork = nil
        super.tearDown()
    }
    
    func test_fetchPhotoGrid_success() async throws {
        // Given
        mockNetwork.mockData = createPhotoGalleryJSON()
        
        // When
        let result = try await sut.fetchPhotoGrid()
        
        // Then
        XCTAssertEqual(mockNetwork.sendCallCount, 1)
        XCTAssertEqual(result.count, 3)
        
        let firstPhoto = try XCTUnwrap(result.first)
        XCTAssertEqual(firstPhoto.id, "1")
        XCTAssertEqual(firstPhoto.author, "Test Author 1")
        XCTAssertEqual(firstPhoto.width, 1000)
        XCTAssertEqual(firstPhoto.height, 800)
        XCTAssertEqual(firstPhoto.url, "https://example.com/photo1")
        XCTAssertEqual(firstPhoto.downloadUrl, "https://example.com/download1")
        
        let secondPhoto = result[1]
        XCTAssertEqual(secondPhoto.id, "2")
        XCTAssertEqual(secondPhoto.author, "Test Author 2")
        XCTAssertEqual(secondPhoto.width, 1200)
        XCTAssertEqual(secondPhoto.height, 900)
    }
    
    func test_fetchPhotoGrid_emptyResponse_returnsEmptyArray() async throws {
        // Given
        mockNetwork.mockData = createEmptyGalleryJSON()
        
        // When
        let result = try await sut.fetchPhotoGrid()
        
        // Then
        XCTAssertEqual(mockNetwork.sendCallCount, 1)
        XCTAssertTrue(result.isEmpty)
    }

    func test_fetchPhotoGrid_networkError() async {
        // Given
        mockNetwork.mockError = NetworkError.serverError(500)
         
        // When & Then
        do {
            _ = try await sut.fetchPhotoGrid()
            XCTFail("Expected error")
        } catch NetworkError.serverError(let code) {
            XCTAssertEqual(code, 500)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        XCTAssertEqual(mockNetwork.sendCallCount, 1)
    }

    func test_fetchPhotoGrid_sendsCorrectRequestConfiguration() async throws {
        // Given
        mockNetwork.mockData = createPhotoGalleryJSON()
        
        // When
        _ = try await sut.fetchPhotoGrid()
        
        // Then
        XCTAssertEqual(mockNetwork.sendCallCount, 1)
        XCTAssertNotNil(mockNetwork.lastRequest)
        
        // Verify request properties
        let request = mockNetwork.lastRequest!
        XCTAssertEqual(request.method, HTTP.Method.GET)
        XCTAssertEqual(request.endpoint.base, "https://picsum.photos/v2")
        XCTAssertEqual(request.endpoint.path, "/list")
        XCTAssertEqual(request.endpoint.queryParameters?["limit"], "100")
    }
    
    func test_fetchPhotoGrid_multipleCalls_callsNetworkMultipleTimes() async throws {
        // Given
        mockNetwork.mockData = createEmptyGalleryJSON()
        
        // When
        _ = try await sut.fetchPhotoGrid()
        _ = try await sut.fetchPhotoGrid()
        _ = try await sut.fetchPhotoGrid()
        
        // Then
        XCTAssertEqual(mockNetwork.sendCallCount, 3)
    }
    
    func test_photoURLGeneration_withValidDimensions_generatesCorrectURLs() {
        // Given
        let photo = Photo(
            id: "123",
            author: "Test Author",
            width: 1000,
            height: 800,
            url: "https://example.com/photo",
            downloadUrl: "https://example.com/download"
        )
        
        // When & Then
        XCTAssertNotNil(photo.smallImageURL)
        XCTAssertEqual(photo.smallImageURL?.absoluteString, "https://picsum.photos/id/123/300/240")
        
        XCTAssertNotNil(photo.bigImageURL)
        XCTAssertEqual(photo.bigImageURL?.absoluteString, "https://picsum.photos/id/123/1500/1200")
    }
    
    func test_photoURLGeneration_withZeroDimensions_returnsDownloadUrl() {
        // Given
        let photo = Photo(
            id: "123",
            author: "Test Author",
            width: 0,
            height: 0,
            url: "https://example.com/photo",
            downloadUrl: "https://example.com/download"
        )
        
        // When & Then
        XCTAssertEqual(photo.smallImageURL?.absoluteString, photo.downloadUrl, "Should return downloadUrl when width is zero")
        XCTAssertEqual(photo.bigImageURL?.absoluteString, photo.downloadUrl, "Should return downloadUrl when width is zero")
    }
    
    // MARK: - Helpers
    private func createPhotoGalleryJSON() -> Data {
        return loadTestData(from: "photo_gallery")
    }
    
    private func createEmptyGalleryJSON() -> Data {
        return loadTestData(from: "empty_gallery")
    }
    
    private func loadTestData(from fileName: String) -> Data {
        guard let path = Bundle(for: type(of: self)).path(forResource: fileName, ofType: "json"),
              let data = NSData(contentsOfFile: path) as Data? else {
            XCTFail("Could not load test data from \(fileName).json")
            return Data()
        }
        return data
    }
}

import XCTest
import SwiftUI
@testable import PhotoGrid

final class NavigatorTests: XCTestCase {
    private var sut: Navigator!
    
    override func setUp() {
        super.setUp()
        sut = Navigator()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testNavigateToDestination_AddsToPath() {
        // Given
        let destination = NavigationDestination.photoDetail(photo: createMockPhoto(id: "1"))
        
        // When
        sut.navigate(to: destination)
        
        // Then
        XCTAssertEqual(sut.path.count, 1)
        
        // When - Navigate to second destination
        let destination2 = NavigationDestination.photoDetail(photo: createMockPhoto(id: "2"))
        sut.navigate(to: destination2)
        
        // Then - Path should have both destinations
        XCTAssertEqual(sut.path.count, 2)
    }
    
    func testNavigateBack_RemovesLastItem() {
        // Given - Empty path
        XCTAssertEqual(sut.path.count, 0)
        
        // When - Navigate back on empty path
        sut.navigateBack()
        
        // Then - Should do nothing
        XCTAssertEqual(sut.path.count, 0)
        
        // Given - Single item in path
        let destination = NavigationDestination.photoDetail(photo: createMockPhoto(id: "1"))
        sut.navigate(to: destination)
        
        // When - Navigate back with single item
        sut.navigateBack()
        
        // Then - Should remove the item
        XCTAssertEqual(sut.path.count, 0)
        
        // Given - Multiple items in path
        let destination1 = NavigationDestination.photoDetail(photo: createMockPhoto(id: "1"))
        let destination2 = NavigationDestination.photoDetail(photo: createMockPhoto(id: "2"))
        sut.navigate(to: destination1)
        sut.navigate(to: destination2)
        
        // When - Navigate back with multiple items
        sut.navigateBack()
        
        // Then - Should remove only the last item
        XCTAssertEqual(sut.path.count, 1)
    }
    
    func testNavigateToRoot_RemovesAllItems() {
        // Given - Empty path
        XCTAssertEqual(sut.path.count, 0)
        
        // When - Navigate to root on empty path
        sut.navigateToRoot()
        
        // Then - Should do nothing
        XCTAssertEqual(sut.path.count, 0)
        
        // Given - Single item in path
        let destination = NavigationDestination.photoDetail(photo: createMockPhoto(id: "1"))
        sut.navigate(to: destination)
        
        // When - Navigate to root with single item
        sut.navigateToRoot()
        
        // Then - Should remove the item
        XCTAssertEqual(sut.path.count, 0)
        
        // Given - Multiple items in path
        let destination1 = NavigationDestination.photoDetail(photo: createMockPhoto(id: "1"))
        let destination2 = NavigationDestination.photoDetail(photo: createMockPhoto(id: "2"))
        sut.navigate(to: destination1)
        sut.navigate(to: destination2)
        
        // When - Navigate to root with multiple items
        sut.navigateToRoot()
        
        // Then - Should remove all items
        XCTAssertEqual(sut.path.count, 0)
    }
    
    func testSheetPresentation_WorksCorrectly() {
        // Given - No active sheet
        XCTAssertNil(sut.sheet)
        
        // When - Present first sheet
        let destination1 = NavigationDestination.photoDetail(photo: createMockPhoto(id: "1"))
        sut.presentSheet(destination1)
        
        // Then - Sheet should be set
        XCTAssertEqual(sut.sheet, destination1)
        
        // When - Present second sheet (overwrites first)
        let destination2 = NavigationDestination.photoDetail(photo: createMockPhoto(id: "2"))
        sut.presentSheet(destination2)
        
        // Then - Sheet should be updated
        XCTAssertEqual(sut.sheet, destination2)
        
        // When - Dismiss sheet
        sut.dismissSheet()
        
        // Then - Sheet should be nil
        XCTAssertNil(sut.sheet)
        
        // When - Dismiss sheet when already nil
        sut.dismissSheet()
        
        // Then - Should remain nil
        XCTAssertNil(sut.sheet)
    }
    
    func testNavigationDestination_PhotoDetail_ContainsCorrectPhoto() {
        // Given & When
        let mockPhoto = createMockPhoto(id: "1")
        let destination = NavigationDestination.photoDetail(photo: mockPhoto)
        
        // Then
        switch destination {
        case .photoDetail(let photo):
            XCTAssertEqual(photo.id, mockPhoto.id)
            XCTAssertEqual(photo.author, mockPhoto.author)
            XCTAssertEqual(photo.width, mockPhoto.width)
            XCTAssertEqual(photo.height, mockPhoto.height)
            XCTAssertEqual(photo.url, mockPhoto.url)
            XCTAssertEqual(photo.downloadUrl, mockPhoto.downloadUrl)
        }
    }
    
    func testNavigationDestination_Identifiable_ReturnsSelfAsId() {
        // Given & When
        let destination = NavigationDestination.photoDetail(photo: createMockPhoto(id: "1"))
        
        // Then
        XCTAssertEqual(destination.id, destination)
    }
    
    func testNavigationDestination_Hashable_CanBeUsedInSet() {
        // Given
        let destination1 = NavigationDestination.photoDetail(photo: createMockPhoto(id: "1"))
        let destination2 = NavigationDestination.photoDetail(photo: createMockPhoto(id: "2"))
        
        // When
        var destinations = Set<NavigationDestination>()
        destinations.insert(destination1)
        destinations.insert(destination2)
        
        // Then
        XCTAssertEqual(destinations.count, 2)
        XCTAssertTrue(destinations.contains(destination1))
        XCTAssertTrue(destinations.contains(destination2))
    }
    
    func testNavigator_CompleteNavigationFlow() {
        // Given
        let destination1 = NavigationDestination.photoDetail(photo: createMockPhoto(id: "1"))
        let destination2 = NavigationDestination.photoDetail(photo: createMockPhoto(id: "2"))
        
        // When - Navigate to multiple destinations
        sut.navigate(to: destination1)
        sut.navigate(to: destination2)
        
        // Then - Verify path
        XCTAssertEqual(sut.path.count, 2)
        
        // When - Present sheet
        sut.presentSheet(destination1)
        
        // Then - Verify sheet
        XCTAssertEqual(sut.sheet, destination1)
        
        // When - Navigate back
        sut.navigateBack()
        
        // Then - Verify path reduced
        XCTAssertEqual(sut.path.count, 1)
        
        // When - Dismiss sheet
        sut.dismissSheet()
        
        // Then - Verify sheet dismissed
        XCTAssertNil(sut.sheet)
        
        // When - Navigate to root
        sut.navigateToRoot()
        
        // Then - Verify path cleared
        XCTAssertEqual(sut.path.count, 0)
    }
    
    // MARK: - Test Helpers
    private func createMockPhoto(id: String) -> Photo {
        Photo(
            id: id,
            author: "Test Author",
            width: 1000,
            height: 800,
            url: "https://example.com/photo\(id)",
            downloadUrl: "https://example.com/download\(id)"
        )
    }
}

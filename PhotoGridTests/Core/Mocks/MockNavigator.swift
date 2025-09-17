import Foundation
import Networking
@testable import PhotoGrid

final class MockNavigator: Navigating {
    var presentedSheet: NavigationDestination?
    var navigateCallCount = 0
    var navigateBackCallCount = 0
    var navigateToRootCallCount = 0
    var dismissSheetCallCount = 0
    
    func navigate(to destination: NavigationDestination) {
        navigateCallCount += 1
    }
    
    func navigateBack() {
        navigateBackCallCount += 1
    }
    
    func navigateToRoot() {
        navigateToRootCallCount += 1
    }
    
    func presentSheet(_ destination: NavigationDestination) {
        presentedSheet = destination
    }
    
    func dismissSheet() {
        dismissSheetCallCount += 1
        presentedSheet = nil
    }
    
    func reset() {
        presentedSheet = nil
        navigateCallCount = 0
        navigateBackCallCount = 0
        navigateToRootCallCount = 0
        dismissSheetCallCount = 0
    }
}

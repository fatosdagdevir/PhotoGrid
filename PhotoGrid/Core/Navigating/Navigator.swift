import SwiftUI

enum NavigationDestination: Hashable, Identifiable {
    var id: Self { return self }
    
    case photoDetail(photo: Photo)
}

protocol Navigating {
    func navigate(to destination: NavigationDestination)
    func navigateBack()
    func navigateToRoot()
    func presentSheet(_ destination: NavigationDestination)
    func dismissSheet()
}

final class Navigator: Navigating, ObservableObject {
    @Published public var path = NavigationPath()
    @Published public var sheet: NavigationDestination?
    
    func navigate(to destination: NavigationDestination) {
        path.append(destination)
    }
    
    func navigateBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func navigateToRoot() {
        guard !path.isEmpty else { return }
        path.removeLast(path.count)
    }
    
    func presentSheet(_ destination: NavigationDestination) {
        sheet = destination
    }
    
    func dismissSheet() {
        sheet = nil
    }
}

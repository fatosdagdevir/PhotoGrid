import Foundation

@MainActor
final class FavouritesViewModel: ObservableObject {
    // MARK: - Private Properties
    private let navigator: Navigating
    
    init(navigator: Navigating) {
        self.navigator = navigator
    }
}

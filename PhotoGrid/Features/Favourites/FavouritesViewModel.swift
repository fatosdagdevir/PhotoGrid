import Foundation

@MainActor
final class FavouritesViewModel: ObservableObject {
    private let navigator: Navigating
    
    init(navigator: Navigating) {
        self.navigator = navigator
    }
}

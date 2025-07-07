import Foundation

@MainActor
final class PhotoGridViewModel: ObservableObject {
    private let navigator: Navigating
    
    init(navigator: Navigating) {
        self.navigator = navigator
    }
}

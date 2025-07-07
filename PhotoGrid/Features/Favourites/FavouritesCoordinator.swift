import SwiftUI

struct FavouritesCoordinator: View {
    @ObservedObject var navigator: Navigator
    @StateObject private var viewModel: FavouritesViewModel
    
    init(
        navigator: Navigator
    ) {
        self.navigator = navigator
        self._viewModel = StateObject(wrappedValue: FavouritesViewModel(
            navigator: navigator
        ))
    }
    
    var body: some View {
        FavouritesView(viewModel: viewModel)
    }
}

import SwiftUI

struct PhotoGridCoordinator: View {
    @ObservedObject var navigator: Navigator
    @StateObject private var viewModel: PhotoGridViewModel
    
    init(
        navigator: Navigator
    ) {
        self.navigator = navigator
        self._viewModel = StateObject(wrappedValue: PhotoGridViewModel(
            navigator: navigator,
            fetchPhotoGridUseCase: FetchPhotoGridUseCase(photoProvider: PhotoProvider())
        ))
    }
    
    var body: some View {
        PhotoGridView(viewModel: viewModel)
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .photoDetail(let photo):
                    PhotoDetailView(
                        photo: photo,
                        onDismiss: {
                            navigator.navigateBack()
                        }
                    )
                }
            }
    }
}

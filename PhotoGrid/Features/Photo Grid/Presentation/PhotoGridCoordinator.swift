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
            .sheet(item: $navigator.sheet) { destination in
                NavigationStack {
                    switch destination {
                    case .photoDetail(let photo):
                        PhotoDetailView(photo: photo) {
                            navigator.dismissSheet()
                        }
                    }
                }
            }
    }
}

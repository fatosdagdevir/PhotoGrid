import SwiftUI

extension PreviewProvider {
    static func previewGridViewModel(state: PhotoGridView.ViewState) -> PhotoGridViewModel {
        let provider = PhotoProvider()
        let fetchPhotoGridUseCase = FetchPhotoGridUseCase(photoProvider: provider)
        let viewModel = PhotoGridViewModel(
            navigator: Navigator(),
            fetchPhotoGridUseCase: fetchPhotoGridUseCase
        )
        viewModel.viewState = state
        return viewModel
    }
}

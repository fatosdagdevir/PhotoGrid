import SwiftUI

extension PreviewProvider {
    static var previewErrorViewModel: ErrorViewModel {
        ErrorViewModel(
            error: URLError(.notConnectedToInternet),
            action: {}
        )
    }
}

import SwiftUI

struct PhotoGridView: View {
    @ObservedObject var viewModel: PhotoGridViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    PhotoGridView(
        viewModel: .init(navigator: Navigator())
    )
}

import SwiftUI

struct FavouritesView: View {
    @ObservedObject var viewModel: FavouritesViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.fill")
                .imageScale(.large)
                .foregroundStyle(.red)
                .font(.system(size: 30))
            
            Text("Your favourite photos will appear here")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .navigationBarTitleDisplayMode(.automatic)
    }
}

#Preview {
    FavouritesView(
        viewModel: .init(navigator: Navigator())
    )
}

import SwiftUI

struct FavouritesView: View {
    @ObservedObject var viewModel: FavouritesViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.fill")
                .imageScale(.large)
                .foregroundStyle(.red)
                .font(.system(size: 40))
            
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
    NavigationStack {
        FavouritesView(
            viewModel: .init(navigator: Navigator())
        )
    }
}

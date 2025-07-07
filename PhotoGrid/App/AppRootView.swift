import SwiftUI

struct AppRootView: View {
    @StateObject private var navigator: Navigator
    
    init() {
        let navigator = Navigator()
        self._navigator = StateObject(wrappedValue: navigator)
    }
    
    var body: some View {
        TabView {
            NavigationStack(path: $navigator.path) {
                PhotoGridCoordinator(navigator: navigator)
            }
            .tabItem {
                Image(systemName: "photo.on.rectangle.angled")
                Text("Photo Grid")
            }
            
            NavigationStack(path: $navigator.path) {
                FavouritesCoordinator(navigator: navigator)
            }
            .tabItem {
                Image(systemName: "heart.fill")
                Text("Favourites")
            }
        }
    }
}

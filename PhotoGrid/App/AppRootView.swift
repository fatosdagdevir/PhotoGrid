import SwiftUI
import SwiftData

struct AppRootView: View {
    @StateObject private var navigator: Navigator
    @Environment(\.modelContext) private var modelContext
    
    private var favouritesManager: FavouritesManaging {
        FavouritesManager(modelContext: modelContext)
    }
    
    init() {
        let navigator = Navigator()
        self._navigator = StateObject(wrappedValue: navigator)
    }
    
    var body: some View {
        TabView {
            NavigationStack(path: $navigator.path) {
                PhotoGridCoordinator(
                    navigator: navigator,
                    favouritesManager: favouritesManager
                )
            }
            .tabItem {
                Image(systemName: "photo.on.rectangle.angled")
                Text("Photo Grid")
            }
            
            NavigationStack(path: $navigator.path) {
                FavouritesCoordinator(
                    navigator: navigator,
                    favouritesManager: favouritesManager
                )
            }
            .tabItem {
                Image(systemName: "heart.fill")
                Text("Favourites")
            }
        }
    }
}

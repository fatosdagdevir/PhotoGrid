import SwiftUI
import SwiftData

struct AppRootView: View {
    @StateObject private var photoGridNavigator: Navigator
    @StateObject private var favouritesNavigator: Navigator
    @State private var photoService: PhotoService
    @State private var favouritesManager: FavouritesManaging
    @Environment(\.modelContext) private var modelContext
    
    init() {
        let photoGridNavigator = Navigator()
        let favouritesNavigator = Navigator()
        self._photoGridNavigator = StateObject(wrappedValue: photoGridNavigator)
        self._favouritesNavigator = StateObject(wrappedValue: favouritesNavigator)
        
        let photoProvider = PhotoProvider()
        let photoService = PhotoService(photoProvider: photoProvider)
        self._photoService = State(wrappedValue: photoService)
        
        // Initialize favouritesManager in onAppear since we need modelContext
        self._favouritesManager = State(wrappedValue: FavouritesManager(
            modelContext: ModelContext(try! ModelContainer(for: FavouritePhoto.self))
        ))
    }
    
    var body: some View {
        TabView {
            NavigationStack(path: $photoGridNavigator.path) {
                PhotoGridCoordinator(
                    navigator: photoGridNavigator,
                    photoService: photoService,
                    favouritesManager: favouritesManager
                )
            }
            .tabItem {
                Image(systemName: "photo.on.rectangle.angled")
                Text("Photo Grid")
            }
            
            NavigationStack(path: $favouritesNavigator.path) {
                FavouritesCoordinator(
                    navigator: favouritesNavigator,
                    photoService: photoService,
                    favouritesManager: favouritesManager
                )
            }
            .tabItem {
                Image(systemName: "heart.fill")
                Text("Favourites")
            }
        }
        .onAppear {
            // Update favouritesManager with the actual modelContext from environment
            favouritesManager = FavouritesManager(modelContext: modelContext)
        }
    }
}

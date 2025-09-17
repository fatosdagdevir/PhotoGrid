import SwiftUI
import SwiftData

struct AppRootView: View {
    // MARK: - Private Properties
    private let dependencyFactory: DependencyFactoryProtocol
    private let photoService: PhotoServicing
    private let favouritesManager: FavouritesManaging
    
    // MARK: - Dependencies
    @StateObject private var photoGridNavigator: Navigator
    @StateObject private var favouritesNavigator: Navigator
 
    // MARK: - Initialization
    init(dependencyFactory: DependencyFactoryProtocol = DependencyFactory()) {
        self.dependencyFactory = dependencyFactory
        self.photoService = dependencyFactory.makePhotoService()
        self.favouritesManager = dependencyFactory.makeFavouritesManager()
        
        self._photoGridNavigator = StateObject(
            wrappedValue: dependencyFactory.makeNavigator()
        )
        self._favouritesNavigator = StateObject(
            wrappedValue: dependencyFactory.makeNavigator()
        )
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
    }
}
